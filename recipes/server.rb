#
# Cookbook Name:: chef-teamcity
# Recipe:: server
#
# Copyright (C) 2014 Alex Falkowski
#
# All rights reserved - Do Not Redistribute
#

group 'teamcity'

user 'teamcity' do
  comment 'TeamCity user.'
  gid 'teamcity'
  shell '/bin/bash'
  password '$1$ByY03mDX$4pk9wp9bC19yB6pxSoVB81'
end

remote_file 'opt/TeamCity-8.1.5.tar.gz' do
  source 'http://download.jetbrains.com/teamcity/TeamCity-8.1.5.tar.gz'
  owner 'teamcity'
  group 'teamcity'
  mode '0644'
end
