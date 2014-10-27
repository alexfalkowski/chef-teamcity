#
# Cookbook Name:: chef-teamcity
# Recipe:: server
#
# Copyright (C) 2014 Alex Falkowski
#
# All rights reserved - Do Not Redistribute
#

TEAMCITY_VERSION = node['teamcity']['version'].freeze
TEAMCITY_USERNAME = node['teamcity']['username'].freeze
TEAMCITY_PASSWORD = node['teamcity']['password'].freeze
TEAMCITY_SERVICE_NAME = node['teamcity']['service_name'].freeze.freeze
TEAMCITY_GROUP = node['teamcity']['group'].freeze
TEAMCITY_DB_USERNAME = node['teamcity']['server']['database']['username'].freeze
TEAMCITY_DB_PASSWORD = node['teamcity']['server']['database']['password'].freeze
TEAMCITY_DB_CONNECTION_URL = node['teamcity']['server']['database']['connection_url'].freeze
TEAMCITY_PATH = "/opt/TeamCity-#{TEAMCITY_VERSION}".freeze
TEAMCITY_SRC_PATH = "#{TEAMCITY_PATH}.tar.gz".freeze
TEAMCITY_SERVER_EXECUTABLE = "#{TEAMCITY_PATH}/bin/teamcity-server.sh".freeze
TEAMCITY_DATA_PATH = "#{TEAMCITY_PATH}/.BuildServer".freeze
TEAMCITY_LIB_PATH = "#{TEAMCITY_DATA_PATH}/lib".freeze
TEAMCITY_JDBC_PATH = "#{TEAMCITY_LIB_PATH}/jdbc".freeze
TEAMCITY_CONFIG_PATH = "#{TEAMCITY_DATA_PATH}/config".freeze
TEAMCITY_DATABASE_PROPS = "#{TEAMCITY_CONFIG_PATH}/database.properties".freeze
TEAMCITY_INIT_LOCATION = "/etc/init.d/#{TEAMCITY_SERVICE_NAME}".freeze
TEAMCITY_PID_FILE = "#{TEAMCITY_PATH}/logs/#{TEAMCITY_SERVICE_NAME}.pid".freeze
TEAMCITY_JAR_URI = node['teamcity']['server']['database']['jar']
TEAMCITY_JAR_NAME = File.basename(URI.parse(TEAMCITY_JAR_URI).path).freeze
TEAMCITY_EXECUTABLE_MODE = 0755
TEAMCITY_READ_MODE = 0644

group TEAMCITY_USERNAME

user TEAMCITY_USERNAME do
  gid TEAMCITY_USERNAME
  shell '/bin/bash'
  password TEAMCITY_PASSWORD
end

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
  not_if { ::File.exists?(TEAMCITY_PATH) }
end

[TEAMCITY_DATA_PATH, TEAMCITY_LIB_PATH, TEAMCITY_JDBC_PATH, TEAMCITY_CONFIG_PATH].each do |p|
  directory p do
    owner TEAMCITY_USERNAME
    group TEAMCITY_GROUP
    recursive true
    mode TEAMCITY_EXECUTABLE_MODE
  end
end

template TEAMCITY_INIT_LOCATION do
  source 'teamcity_server_init.erb'
  mode TEAMCITY_EXECUTABLE_MODE
  owner 'root'
  group 'root'
  variables({
              teamcity_user_name: TEAMCITY_USERNAME,
              teamcity_server_executable: TEAMCITY_SERVER_EXECUTABLE,
              teamcity_data_path: TEAMCITY_DATA_PATH,
              teamcity_pidfile: TEAMCITY_PID_FILE,
              teamcity_service_name: TEAMCITY_SERVICE_NAME
            })
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
end

remote_file "#{TEAMCITY_JDBC_PATH}/#{TEAMCITY_JAR_NAME}" do
  source TEAMCITY_JAR_URI
  owner TEAMCITY_USERNAME
  group TEAMCITY_GROUP
  mode TEAMCITY_READ_MODE
end

template TEAMCITY_DATABASE_PROPS do
  source 'database.properties.erb'
  mode TEAMCITY_READ_MODE
  owner TEAMCITY_USERNAME
  group TEAMCITY_USERNAME
  variables({
              url: TEAMCITY_DB_CONNECTION_URL,
              username: TEAMCITY_DB_USERNAME,
              password: TEAMCITY_DB_PASSWORD,
            })
  notifies :restart, "service[#{TEAMCITY_SERVICE_NAME}]", :delayed
end

service TEAMCITY_SERVICE_NAME do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :start]
end
