#
# Cookbook Name:: prometheus
# Recipe:: alertmanager
#
# Author: Paul Magrath <paul@paulmagrath.com>
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

directory '/var/lib/prometheus/data' do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

user node['prometheus']['user'] do
  system true
  shell '/bin/false'
  home '/var/lib/prometheus'
  not_if { node['prometheus']['use_existing_user'] == true || node['prometheus']['user'] == 'root' }
end

directory node['prometheus']['log_dir'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end


# -- Write our Config -- #

template '/etc/prometheus/alertmanager.conf' do
  source    node['prometheus']['alertmanager']['config_template_name']
  mode      '0644'
  variables(
    notification_config: node['prometheus']['alertmanager']['notification']
  )
  notifies  :restart, 'service[alertmanager]'
end

# -- Do the install -- #

include_recipe 'ark::default'

%w(curl tar bzip2).each do |pkg|
  package pkg
end

ark 'alertmanager' do
  url node['prometheus']['alertmanager']['binary_url']
  checksum node['prometheus']['alertmanager']['checksum']
  version node['prometheus']['alertmanager']['version']
  action :put
end

# rubocop:disable Style/HashSyntax
dist_dir, conf_dir, env_file = value_for_platform_family(
  ['fedora'] => %w(fedora sysconfig alertmanager),
  ['rhel'] => %w(redhat sysconfig alertmanager),
  ['debian'] => %w(debian default alertmanager)
)

template '/etc/systemd/system/alertmanager.service' do
  source 'systemd/alertmanager.service.erb'
  mode '0644'
  variables(:sysconfig_file => "/etc/#{conf_dir}/#{env_file}")
  notifies :restart, 'service[alertmanager]', :delayed
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

template "/etc/#{conf_dir}/#{env_file}" do
  source "#{dist_dir}/#{conf_dir}/alertmanager.erb"
  mode '0644'
  notifies :restart, 'service[alertmanager]', :delayed
end

execute 'systemctl daemon-reload' do
  command '/bin/systemctl daemon-reload'
  action :nothing
end

service 'alertmanager' do
  supports :status => true, :restart => true
  action [:enable, :start]
end
