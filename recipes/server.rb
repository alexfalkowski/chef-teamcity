#
# Cookbook Name:: chef-teamcity
# Recipe:: server
#
# Copyright (C) 2014 Alex Falkowski
#
# All rights reserved - Do Not Redistribute
#

VERSION = '8.1.5'
USER_NAME = 'teamcity'
SRC_PATH = "/opt/TeamCity-#{VERSION}.tar.gz".freeze
EXTRACT_PATH = "/opt/TeamCity-#{VERSION}".freeze

group USER_NAME

user USER_NAME do
  gid USER_NAME
  shell '/bin/bash'
  password '$1$ByY03mDX$4pk9wp9bC19yB6pxSoVB81'
end

remote_file SRC_PATH do
  source "http://download.jetbrains.com/teamcity/TeamCity-#{VERSION}.tar.gz"
  owner USER_NAME
  group USER_NAME
  mode '0644'
end

bash 'extract_teamcity' do
  cwd '/opt'
  code <<-EOH
    mkdir -p #{EXTRACT_PATH}
    tar xzf #{SRC_PATH} -C #{EXTRACT_PATH}
    mv #{EXTRACT_PATH}/*/* #{EXTRACT_PATH}/
  EOH
  not_if { ::File.exists?(EXTRACT_PATH) }
end
