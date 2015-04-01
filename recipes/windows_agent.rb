#
# Cookbook Name:: chef-teamcity
# Recipe:: agent-windows
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TEAMCITY_VERSION = node['teamcity']['version'].freeze
TEAMCITY_SERVICE_NAME = 'TCBuildAgent'.freeze

TEAMCITY_AGENT_NAME = node['teamcity']['agent']['name'].freeze
TEAMCITY_AGENT_SERVER_URI = node['teamcity']['agent']['server_uri'].freeze
TEAMCITY_AGENT_FILE = 'buildAgent.zip'.freeze
TEAMCITY_AGENT_URI = ::URI.join(TEAMCITY_AGENT_SERVER_URI, "update/#{TEAMCITY_AGENT_FILE}").to_s.freeze
TEAMCITY_AGENT_WORK_DIR = node['teamcity']['agent']['work_dir'].freeze
TEAMCITY_AGENT_TEMP_DIR = node['teamcity']['agent']['temp_dir'].freeze
TEAMCITY_AGENT_SYSTEM_DIR = node['teamcity']['agent']['system_dir'].freeze
TEAMCITY_AGENT_OWN_ADDRESS = node['teamcity']['agent']['own_address'].freeze
TEAMCITY_AGENT_OWN_PORT = node['teamcity']['agent']['port'].freeze
TEAMCITY_AGENT_AUTH_TOKEN = node['teamcity']['agent']['authorization_token'].freeze
TEAMCITY_AGENT_SYSTEM_PROPERTIES = node['teamcity']['agent']['system_properties'].freeze
TEAMCITY_AGENT_ENV_PROPERTIES = node['teamcity']['agent']['env_properties'].freeze
TEAMCITY_AGENT_SRC_PATH = ::File.join(TEAMCITY_AGENT_SYSTEM_DIR, TEAMCITY_AGENT_FILE).freeze
TEAMCITY_AGENT_CONFIG_PATH = "#{TEAMCITY_AGENT_SYSTEM_DIR}/conf".freeze
TEAMCITY_AGENT_PROPERTIES = "#{TEAMCITY_AGENT_CONFIG_PATH}/buildAgent.properties".freeze
TEAMCITY_AGENT_BIN_PATH = ::File.join(TEAMCITY_AGENT_SYSTEM_DIR, 'bin')

TEAMCITY_SRC_PATH = "#{TEAMCITY_AGENT_SYSTEM_DIR}.zip".freeze
TEAMCITY_PID_FILE = "#{TEAMCITY_AGENT_SYSTEM_DIR}\\logs\\buildAgent.pid".freeze

remote_file TEAMCITY_SRC_PATH do
  source TEAMCITY_AGENT_URI
  not_if { ::File.exist?(TEAMCITY_AGENT_CONFIG_PATH) }
end

directory TEAMCITY_AGENT_SYSTEM_DIR do
  action :create
  recursive true
  not_if { ::File.exist?(TEAMCITY_AGENT_CONFIG_PATH) }
end

windows_zipfile TEAMCITY_AGENT_SYSTEM_DIR do
  source TEAMCITY_SRC_PATH
  action :unzip
  not_if { ::File.exist?(TEAMCITY_AGENT_BIN_PATH) }
end

template TEAMCITY_AGENT_PROPERTIES do
  source 'buildAgent.properties.erb'
  variables(
              server_uri: TEAMCITY_AGENT_SERVER_URI,
              name: TEAMCITY_AGENT_NAME,
              work_dir: TEAMCITY_AGENT_WORK_DIR,
              temp_dir: TEAMCITY_AGENT_TEMP_DIR,
              system_dir: TEAMCITY_AGENT_SYSTEM_DIR,
              own_address: TEAMCITY_AGENT_OWN_ADDRESS,
              own_port: TEAMCITY_AGENT_OWN_PORT,
              authorization_token: TEAMCITY_AGENT_AUTH_TOKEN,
              system_properties: TEAMCITY_AGENT_SYSTEM_PROPERTIES,
              env_properties: TEAMCITY_AGENT_ENV_PROPERTIES
            )
  not_if { ::File.exist?(TEAMCITY_AGENT_PROPERTIES) }
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
end

execute 'install teamcity service' do
  command "#{TEAMCITY_AGENT_BIN_PATH}/service.install.bat"
  action :run
  cwd "#{TEAMCITY_AGENT_SYSTEM_DIR}/bin"
  not_if { ::Win32::Service.exists?('TCBuildAgent') }
end

service TEAMCITY_SERVICE_NAME do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :start]
end
