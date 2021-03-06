#
# Cookbook Name:: grafana
# Recipe:: _install_package
#
# Copyright 2015, Michael Lanyon
# Copyright 2017, Andrei Skopenko
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

case node['platform_family']
when 'debian'
  package 'apt-transport-https'

  apt_repository 'grafana' do
    uri node['grafana']['package']['repo']
    distribution node['grafana']['package']['distribution']
    components node['grafana']['package']['components']
    key node['grafana']['package']['key']
    cache_rebuild node['grafana']['package']['apt_rebuild']
    trusted node['grafana']['package']['trusted']
  end

  package 'grafana' do
    version node['grafana']['package']['version']
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
  end
when 'rhel', 'amazon'
  yum_repository 'grafana' do
    description 'Grafana Stable Repo'
    baseurl node['grafana']['package']['repo']
    gpgkey node['grafana']['package']['key']
    gpgcheck node['grafana']['package']['checkkey']
    action :create
  end

  package 'grafana' do
    version node['grafana']['package']['version']
  end
end
