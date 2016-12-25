#
# Cookbook Name:: rdzabbix
# Recipe:: agent
#
# All rights reserved - Do Not Redistribute
#
fail 'Zabbix server is not set on environment!' if node['zabbix']['agent']['servers'].nil?
fail 'Zabbix server is not set on environment!' if node['zabbix']['agent']['servers_active'].nil?

# Manage user and group
if node['zabbix']['agent']['user']
  group node['zabbix']['agent']['group'] do
    gid node['zabbix']['agent']['gid'] if node['zabbix']['agent']['gid']
    system true
  end
  user node['zabbix']['agent']['user'] do
    home node['zabbix']['install_dir']
    shell node['zabbix']['agent']['shell']
    uid node['zabbix']['agent']['uid'] if node['zabbix']['agent']['uid']
    gid node['zabbix']['agent']['gid'] || node['zabbix']['agent']['group']
    system true
    supports :manage_home => true
  end
end

# Define root owned folders
root_dirs = [
  node['zabbix']['etc_dir'],
]
root_dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end
end
zabbix_dirs = [
  node['zabbix']['log_dir'],
  node['zabbix']['run_dir']
]

# Create zabbix folders
zabbix_dirs.each do |dir|
  directory dir do
    owner node['zabbix']['login']
    group node['zabbix']['group']
    mode '755'
    recursive true
    not_if { ::File.world_writable?(dir) }
  end
end

root_dirs = [
  node['zabbix']['agent']['include_dir']
]
root_dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
    notifies :restart, 'service[zabbix_agentd]'
  end
end

# Manage Agent service
case node['zabbix']['agent']['init_style']
when 'sysvinit'
  template '/etc/init.d/zabbix_agentd' do
    source value_for_platform_family(['rhel'] => 'zabbix_agentd.init-rh.erb', 'default' => 'zabbix_agentd.init.erb')
    owner 'root'
    group 'root'
    mode '754'
  end
  service 'zabbix_agentd' do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
end

#Install prerequisite RPM
package 'redhat-lsb' 

ark 'zabbix_agent' do
  name 'zabbix'
  url node['zabbix']['agent']['prebuild']['url']
  owner node['zabbix']['agent']['user']
  group node['zabbix']['agent']['group']
  action :put
  path '/opt'
  strip_components 0
  has_binaries ['bin/zabbix_sender', 'bin/zabbix_get', 'sbin/zabbix_agent', 'sbin/zabbix_agentd']
  notifies :restart, 'service[zabbix_agentd]'
end

# Install configuration
template 'zabbix_agentd.conf' do
  path node['zabbix']['agent']['config_file']
  source 'zabbix_agentd.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[zabbix_agentd]'
end

# Install optional additional agent config file containing UserParameter(s)
template 'user_params.conf' do
  path node['zabbix']['agent']['userparams_config_file']
  source 'user_params.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[zabbix_agentd]'
  only_if { node['zabbix']['agent']['user_parameter'].length > 0 }
end

ruby_block 'start service' do
  block do
    true
  end
  Array(node['zabbix']['agent']['service_state']).each do |action|
    notifies action, 'service[zabbix_agentd]'
  end
end
