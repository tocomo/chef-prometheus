#
# Cookbook Name:: prometheus
# Recipe:: default
#
# Author: Ray Rodriguez <rayrod2030@gmail.com>
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

user node['prometheus']['user'] do
  system true
  shell '/bin/false'
  home '/var/lib/prometheus'
  not_if { node['prometheus']['use_existing_user'] == true || node['prometheus']['user'] == 'root' }
end


directory '/etc/prometheus'

directory node['prometheus']['log_dir'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

directory node['prometheus']['cli_opts']['storage.tsdb.path'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

include_recipe 'ark::default'

%w(curl tar bzip2).each do |pkg|
  package pkg
end

ark 'prometheus' do
  url node['prometheus']['binary_url']
  checksum node['prometheus']['checksum']
  version node['prometheus']['version']
  action :put
end


template '/etc/prometheus/prometheus.yml' do
  source    node['prometheus']['job_config_template_name']
  mode      '0644'
  variables(
    rule_filenames: node['prometheus']['rule_filenames']
  )
  notifies  :reload, 'service[prometheus]'
end

include_recipe 'prometheus::service'
