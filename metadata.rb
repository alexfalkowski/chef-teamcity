name 'chef-teamcity'
maintainer 'Alex Falkowski'
maintainer_email 'alexrfalkowski@gmail.com'
license 'All rights reserved'
description 'Installs/Configures TeamCity agent/server.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'
recipe 'chef-teamcity::server', 'Install a TeamCity server'
recipe 'chef-teamcity::agent', 'Installs a TeamCity agent'

%w{centos}.each do |el|
  supports el, '~> 6.0'
end

depends 'java'
