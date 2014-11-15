#
# Cookbook Name:: chef-teamcity
# Recipe:: agent
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

include_recipe 'java'

TEAMCITY_VERSION = node['teamcity']['version'].freeze
TEAMCITY_USERNAME = node['teamcity']['username'].freeze
TEAMCITY_PASSWORD = node['teamcity']['password'].freeze
TEAMCITY_SERVICE_NAME = node['teamcity']['service_name'].freeze
TEAMCITY_GROUP = node['teamcity']['group'].freeze
TEAMCITY_HOME_PATH = "/home/#{TEAMCITY_USERNAME}".freeze
TEAMCITY_PATH = "/opt/TeamCity-#{TEAMCITY_VERSION}".freeze
TEAMCITY_SRC_PATH = "#{TEAMCITY_PATH}.zip".freeze
TEAMCITY_INIT_LOCATION = "/etc/init.d/#{TEAMCITY_SERVICE_NAME}".freeze
TEAMCITY_PID_FILE = "#{TEAMCITY_PATH}/logs/buildAgent.pid".freeze
TEAMCITY_EXECUTABLE_MODE = 0755
TEAMCITY_READ_MODE = 0644

TEAMCITY_AGENT_NAME = node['teamcity']['agent']['name'].freeze
TEAMCITY_AGENT_SERVER_URI = node['teamcity']['agent']['server_uri'].freeze
TEAMCITY_AGENT_FILE = 'buildAgent.zip'.freeze
TEAMCITY_AGENT_URI = ::URI.join(TEAMCITY_AGENT_SERVER_URI, "update/#{TEAMCITY_AGENT_FILE}").to_s.freeze
TEAMCITY_AGENT_SRC_PATH = ::File.join(TEAMCITY_PATH, TEAMCITY_AGENT_FILE).freeze
TEAMCITY_AGENT_CONFIG_PATH = "#{TEAMCITY_PATH}/conf".freeze
TEAMCITY_AGENT_PROPERTIES = "#{TEAMCITY_AGENT_CONFIG_PATH}/buildAgent.properties".freeze
TEAMCITY_AGENT_EXECUTABLE = "#{TEAMCITY_PATH}/bin/agent.sh".freeze

group TEAMCITY_GROUP

user TEAMCITY_USERNAME do
  supports manage_home: true
  home TEAMCITY_HOME_PATH
  gid TEAMCITY_GROUP
  shell '/bin/bash'
  password TEAMCITY_PASSWORD
end

package 'unzip'

remote_file TEAMCITY_SRC_PATH do
  source TEAMCITY_AGENT_URI
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  mode TEAMCITY_READ_MODE
  not_if { ::File.exists?(TEAMCITY_PATH) }
end

bash 'extract_teamcity' do
  cwd '/opt'
  code <<-EOH
    unzip #{TEAMCITY_SRC_PATH} -d #{TEAMCITY_PATH}
    chown -R #{TEAMCITY_USERNAME}.#{TEAMCITY_GROUP} #{TEAMCITY_PATH}
    rm -f #{TEAMCITY_SRC_PATH}
  EOH
  not_if { ::File.exists?(TEAMCITY_PATH) }
end

file TEAMCITY_AGENT_EXECUTABLE do
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  mode TEAMCITY_EXECUTABLE_MODE
end

[TEAMCITY_AGENT_CONFIG_PATH].each do |p|
  directory p do
    owner TEAMCITY_USERNAME
    group TEAMCITY_GROUP
    recursive true
    mode TEAMCITY_EXECUTABLE_MODE
  end
end

template TEAMCITY_AGENT_PROPERTIES do
  source 'buildAgent.properties.erb'
  mode TEAMCITY_READ_MODE
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  variables({
              server_uri: TEAMCITY_AGENT_SERVER_URI,
              name: TEAMCITY_AGENT_NAME
            })
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
  not_if { ::File.exists?(TEAMCITY_AGENT_PROPERTIES) }
end

template TEAMCITY_INIT_LOCATION do
  source 'teamcity_agent_init.erb'
  mode TEAMCITY_EXECUTABLE_MODE
  owner 'root'
  group 'root'
  variables({
              teamcity_user_name: TEAMCITY_USERNAME,
              teamcity_executable: TEAMCITY_AGENT_EXECUTABLE,
              teamcity_pidfile: TEAMCITY_PID_FILE,
              teamcity_service_name: TEAMCITY_SERVICE_NAME
            })
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
end

service TEAMCITY_SERVICE_NAME do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :start]
end
