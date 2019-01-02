# -*- encoding: utf-8 -*-

#
# Cookbook Name:: jenkins-demo
# Recipe:: master
#
# Copyright 2017, DennyZhang.com
#
# All rights reserved - Do Not Redistribute
#

apt_update 'update' if platform_family?('debian')

node.default['java']['install_flavor'] = 'oracle'
node.default['java']['jdk_version'] = '8'
node.default['java']['set_etc_environment'] = true
node.default['java']['oracle']['accept_oracle_download_terms'] = true
# Avoid unecessary change to /etc/sysconfig/jenkins in CentOS
node.default['jenkins']['java'] = 'java'

if %w[debian ubuntu].include?(node['platform_family'])
  node.default['jenkins']['master']['repository'] = \
    'http://pkg.jenkins-ci.org/debian'
  node.default['jenkins']['master']['repository_key'] = \
    'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key'
end

node.default['jenkins']['executor']['timeout'] = 480

node.default['jenkins']['master']['port'] = node['jenkins_demo']['jenkins_port']
node.default['jenkins']['master']['endpoint'] = \
  "http://#{node['jenkins']['master']['host']}:#{node['jenkins']['master']['port']}"

include_recipe 'java::default'
include_recipe 'jenkins::master'

# Install some plugins needed, but not installed on jenkins2 by default
node['jenkins_demo']['jenkins_plugins'].each do |plugin|
  jenkins_plugin plugin[0] do
    version plugin[1]
    notifies :execute, 'jenkins_command[safe-restart]', :delayed
  end
end

# force restart, since critical jenkins plugin installed
# TODO: When re-run chef update, avoid this extra blind jenkins restart
jenkins_command 'safe-restart' do
  action :execute
end

%w[/var/lib/jenkins/script].each do |x|
  directory x do
    owner 'jenkins'
    group 'jenkins'
    mode 0o755
    action :create
  end
end

include_recipe 'jenkins-demo::security'
include_recipe 'jenkins-demo::backup'
