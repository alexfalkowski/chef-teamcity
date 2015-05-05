name 'chef-teamcity'
maintainer 'Alex Falkowski'
maintainer_email 'alexrfalkowski@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures TeamCity agent/server.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'
recipe 'chef-teamcity::server', 'Install a TeamCity server'
recipe 'chef-teamcity::agent', 'Installs a TeamCity agent'

supports 'redhat', '~> 6.0'
supports 'centos', '~> 6.0'
supports 'windows'

depends 'java'
depends 'git'
depends 'mercurial'
depends 'subversion'
