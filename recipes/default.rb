#
# Cookbook Name:: chef-teamcity
# Recipe:: default
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

TEAMCITY_USERNAME = node['teamcity']['username'].freeze
TEAMCITY_PASSWORD = node['teamcity']['password'].freeze
TEAMCITY_GROUP = node['teamcity']['group'].freeze
TEAMCITY_HOME_PATH = "/home/#{TEAMCITY_USERNAME}".freeze

include_recipe 'java'

include_recipe 'git'
include_recipe 'mercurial'
include_recipe 'subversion'

if node['platform'] != 'windows'
  package 'git'
  package 'mercurial'
  package 'subversion'

  group TEAMCITY_GROUP

  user TEAMCITY_USERNAME do
    supports manage_home: true
    home TEAMCITY_HOME_PATH
    gid TEAMCITY_GROUP
    shell '/bin/bash'
    password TEAMCITY_PASSWORD
  end
end
