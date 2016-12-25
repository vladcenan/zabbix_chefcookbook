#
# Cookbook Name:: rdzabbix 
# Recipe:: monitor 
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'rdzabbix::_provider_gem'

# if zabbix server is 2.2.X zabbixapi requires a specific version of gem and URL will change
if node['zabbix']['agent']['version'] == '2.2.0'
  node.default['zabbix']['monitor']['zabbix_server_url'] = "http://#{node['zabbix']['agent']['servers'].join(',')}/api_jsonrpc.php"
  node.default['zabbix']['monitor']['zabbixapi_gem_version'] = '2.2.0'
else
  node.default['zabbix']['monitor']['zabbix_server_url'] = "http://#{node['zabbix']['agent']['servers'].join(',')}/zabbix/api_jsonrpc.php"
end

if node['zabbix']['hostgroup']
  node.default['zabbix']['monitor']['hostgroup'] = node['zabbix']['hostgroup']
else
  fail 'Zabbix Hostgroup is not set on environment!' if node['zabbix']['hostgroup'].nil?
end

execute 'install zabbixapi gem' do
  command "gem install zabbixapi -v #{node['zabbix']['monitor']['zabbixapi_gem_version']}"
end

# get the credentials from the databag for the current environment
credentials = data_bag_item('rdzabbix', node.chef_environment.downcase)
zabbix_credentials = credentials['zabbixConfig']

fail 'Zabbix server is not set on environment!' if node['zabbix']['agent']['servers'].nil?
fail 'Zabbix agent version is not set on environment!' if node['zabbix']['agent']['version'].nil?
fail 'Zabbix databag is not set for this environment!' if credentials['zabbixConfig'].nil?

user = credentials['zabbixConfig']['username']
pass = credentials['zabbixConfig']['password']

Chef::Zabbix.monitor(node['zabbix']['monitor']['zabbix_server_url'], node['zabbix']['monitor']['hostgroup'], node['zabbix']['monitor']['fqdn'], node['zabbix']['monitor']['ipaddress'], node['zabbix']['monitor']['port'], user, pass) 
