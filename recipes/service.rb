#
# Cookbook Name:: prometheus
# Recipe:: service
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

dist_dir, conf_dir, env_file = value_for_platform_family(
  ['fedora'] => %w[fedora sysconfig prometheus],
  ['rhel'] => %w[redhat sysconfig prometheus],
  ['debian'] => %w[debian default prometheus]
)

template '/etc/systemd/system/prometheus.service' do
  source 'systemd/prometheus.service.erb'
  mode '0644'
  variables(sysconfig_file: "/etc/#{conf_dir}/#{env_file}")
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :restart, 'service[prometheus]', :delayed
end

template "/etc/#{conf_dir}/#{env_file}" do
  source "#{dist_dir}/#{conf_dir}/prometheus.erb"
  mode '0644'
  notifies :restart, 'service[prometheus]', :delayed
end

execute 'systemctl daemon-reload' do
  command '/bin/systemctl daemon-reload'
  action :nothing
end

service 'prometheus' do
  supports status: true, restart: true
  action [:enable, :start]
end
