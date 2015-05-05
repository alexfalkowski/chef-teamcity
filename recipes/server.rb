#
# Cookbook Name:: chef-teamcity
# Recipe:: server
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
TEAMCITY_SERVICE_NAME = node['teamcity']['service_name'].freeze
TEAMCITY_GROUP = node['teamcity']['group'].freeze
TEAMCITY_HOME_PATH = "/home/#{TEAMCITY_USERNAME}".freeze
TEAMCITY_PATH = "/opt/TeamCity-#{TEAMCITY_VERSION}".freeze
TEAMCITY_INIT_LOCATION = "/etc/init.d/#{TEAMCITY_SERVICE_NAME}".freeze
TEAMCITY_EXECUTABLE_MODE = 0755
TEAMCITY_READ_MODE = 0644

TEAMCITY_SRC_PATH = "#{TEAMCITY_PATH}.tar.gz".freeze
TEAMCITY_PID_FILE = "#{TEAMCITY_PATH}/logs/#{TEAMCITY_SERVICE_NAME}.pid".freeze
TEAMCITY_DB_USERNAME = node['teamcity']['server']['database']['username'].freeze
TEAMCITY_DB_PASSWORD = node['teamcity']['server']['database']['password'].freeze
TEAMCITY_DB_CONNECTION_URL = node['teamcity']['server']['database']['connection_url'].freeze
TEAMCITY_SERVER_EXECUTABLE = "#{TEAMCITY_PATH}/bin/teamcity-server.sh".freeze
TEAMCITY_BIN_PATH = "#{TEAMCITY_PATH}/bin".freeze
TEAMCITY_DATA_PATH = "#{TEAMCITY_PATH}/.BuildServer".freeze
TEAMCITY_LIB_PATH = "#{TEAMCITY_DATA_PATH}/lib".freeze
TEAMCITY_JDBC_PATH = "#{TEAMCITY_LIB_PATH}/jdbc".freeze
TEAMCITY_CONFIG_PATH = "#{TEAMCITY_DATA_PATH}/config".freeze
TEAMCITY_BACKUP_PATH = "#{TEAMCITY_DATA_PATH}/backup".freeze
TEAMCITY_DATABASE_PROPS_NAME = 'database.properties'.freeze
TEAMCITY_DATABASE_PROPS_PATH = "#{TEAMCITY_CONFIG_PATH}/#{TEAMCITY_DATABASE_PROPS_NAME}".freeze
TEAMCITY_JAR_URI = node['teamcity']['server']['database']['jar'].freeze
TEAMCITY_BACKUP_FILE = node['teamcity']['server']['backup']
TEAMCITY_JAR_NAME = ::File.basename(URI.parse(TEAMCITY_JAR_URI).path).freeze

include_recipe 'chef-teamcity::default'

remote_file TEAMCITY_SRC_PATH do
  source "http://download.jetbrains.com/teamcity/TeamCity-#{TEAMCITY_VERSION}.tar.gz"
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  mode TEAMCITY_READ_MODE
end

bash 'extract_teamcity' do
  cwd '/opt'
  code <<-EOH
    mkdir -p #{TEAMCITY_PATH}
    tar xzf #{TEAMCITY_SRC_PATH} -C #{TEAMCITY_PATH}
    mv #{TEAMCITY_PATH}/*/* #{TEAMCITY_PATH}/
    chown -R #{TEAMCITY_USERNAME}.#{TEAMCITY_GROUP} #{TEAMCITY_PATH}
  EOH
  not_if { ::File.exist?(TEAMCITY_PATH) }
end

paths = [
  TEAMCITY_DATA_PATH,
  TEAMCITY_LIB_PATH,
  TEAMCITY_JDBC_PATH,
  TEAMCITY_CONFIG_PATH,
  TEAMCITY_BACKUP_PATH
]

paths.each do |p|
  directory p do
    owner TEAMCITY_USERNAME
    group TEAMCITY_GROUP
    recursive true
    mode TEAMCITY_EXECUTABLE_MODE
  end
end

remote_file "#{TEAMCITY_JDBC_PATH}/#{TEAMCITY_JAR_NAME}" do
  source TEAMCITY_JAR_URI
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  mode TEAMCITY_READ_MODE
end

if TEAMCITY_BACKUP_FILE
  backup_file = ::File.basename(URI.parse(TEAMCITY_BACKUP_FILE).path).freeze
  processed_backup_file = File.basename(backup_file, '.*').freeze
  backup_path = ::File.join(TEAMCITY_BACKUP_PATH, backup_file).freeze
  processed_backup_path = ::File.join(TEAMCITY_BACKUP_PATH, processed_backup_file).freeze
  home_database_props = ::File.join(TEAMCITY_HOME_PATH, TEAMCITY_DATABASE_PROPS_NAME).freeze

  remote_file backup_path do
    source TEAMCITY_BACKUP_FILE
    owner TEAMCITY_USERNAME
    group TEAMCITY_GROUP
    mode TEAMCITY_READ_MODE
    not_if { ::File.exist?(processed_backup_path) }
  end

  template home_database_props do
    source 'database.properties.erb'
    mode TEAMCITY_READ_MODE
    owner TEAMCITY_USERNAME
    group TEAMCITY_GROUP
    variables(
                url: TEAMCITY_DB_CONNECTION_URL,
                username: TEAMCITY_DB_USERNAME,
                password: TEAMCITY_DB_PASSWORD
              )
  end

  bash 'restore' do
    user TEAMCITY_USERNAME
    group TEAMCITY_GROUP
    code <<-EOH
      #{TEAMCITY_BIN_PATH}/maintainDB.sh restore -F #{backup_file} -A #{TEAMCITY_DATA_PATH} -T #{home_database_props}
      rm -f #{backup_path}
      touch #{processed_backup_path}
    EOH
    not_if { ::File.exist?(processed_backup_path) }
  end
end

template TEAMCITY_DATABASE_PROPS_PATH do
  source 'database.properties.erb'
  mode TEAMCITY_READ_MODE
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  variables(
              url: TEAMCITY_DB_CONNECTION_URL,
              username: TEAMCITY_DB_USERNAME,
              password: TEAMCITY_DB_PASSWORD
            )
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
end

template TEAMCITY_INIT_LOCATION do
  source 'teamcity_server_init.erb'
  mode TEAMCITY_EXECUTABLE_MODE
  owner 'root'
  group 'root'
  variables(
              teamcity_user_name: TEAMCITY_USERNAME,
              teamcity_server_executable: TEAMCITY_SERVER_EXECUTABLE,
              teamcity_data_path: TEAMCITY_DATA_PATH,
              teamcity_pidfile: TEAMCITY_PID_FILE,
              teamcity_service_name: TEAMCITY_SERVICE_NAME
            )
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
end

service TEAMCITY_SERVICE_NAME do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :start]
end
