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

TEAMCITY_VERSION = node['teamcity']['version'].freeze
TEAMCITY_USERNAME = node['teamcity']['username'].freeze
TEAMCITY_PASSWORD = node['teamcity']['password'].freeze
TEAMCITY_SERVICE_NAME = node['teamcity']['service_name'].freeze
TEAMCITY_GROUP = node['teamcity']['group'].freeze
TEAMCITY_PATH = "/opt/TeamCity-#{TEAMCITY_VERSION}".freeze
TEAMCITY_SRC_PATH = "#{TEAMCITY_PATH}.zip".freeze
TEAMCITY_EXECUTABLE_MODE = 0755
TEAMCITY_READ_MODE = 0644

TEAMCITY_SEVER_HOST = node['teamcity']['agent']['server_uri'].freeze
TEAMCITY_BUILD_AGENT_NAME = 'buildAgent.zip'.freeze
TEAMCITY_BUILD_AGENT_URI = ::URI.join(TEAMCITY_SEVER_HOST, "update/#{TEAMCITY_BUILD_AGENT_NAME}").to_s.freeze
TEAMCITY_AGENT_SRC_PATH = ::File.join(TEAMCITY_PATH, TEAMCITY_BUILD_AGENT_NAME)

group TEAMCITY_USERNAME

user TEAMCITY_USERNAME do
  gid TEAMCITY_USERNAME
  shell '/bin/bash'
  password TEAMCITY_PASSWORD
end

package 'unzip'

remote_file TEAMCITY_SRC_PATH do
  source TEAMCITY_BUILD_AGENT_URI
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
