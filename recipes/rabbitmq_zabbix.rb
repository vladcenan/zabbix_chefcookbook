#
# Cookbook Name:: rdzabbix
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'rdzabbix::monitor'

execute 'ruby_env' do 
  command 'export PATH="/opt/chef/embedded/bin:${HOME}/.chef/gem/ruby/2.1.0/bin:$PATH"'
end

if node['zabbix']['agent']['version'] == '2.2.0'
  serverurl = "http://#{node['zabbix']['agent']['servers'].join(',')}/api_jsonrpc.php"
  zabbixapi_gem_version = '2.2.0'
else
  serverurl = "http://#{node['zabbix']['agent']['servers'].join(',')}/zabbix/api_jsonrpc.php"
  zabbixapi_gem_version = '2.4.8'
end

if node['zabbix']['release']
  release = "#{node['zabbix']['release']}"
else
  fail 'Zabbix Hostgroup is not set on environment!' if node['zabbix']['release'].nil?
end

execute 'install zabbixapi gem' do
  command "gem install zabbixapi -v #{zabbixapi_gem_version}"
end

# get the credentials from the databag for the current environment
credentials = data_bag_item('rdzabbix', node.chef_environment.downcase)
zabbix_credentials = credentials['zabbixConfig']

# Percona Port
port='5672'
port2='15672'

Chef::Zabbix.rabbitmq(serverurl, node['fqdn'], credentials['zabbixConfig']['username'], credentials['zabbixConfig']['password'], port, port2, release)
