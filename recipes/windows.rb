#
# Cookbook Name:: rdzabbix
# Recipe:: windows
#
# All rights reserved - Do Not Redistribute
#
fail 'Zabbix server is not set on environment!' if node['zabbix']['agent']['servers'].nil?

include_recipe 'chocolatey'
chocolatey 'zabbix-agent'

# Manage user and group
if node['zabbix']['agent']['user']
  group node['zabbix']['agent']['group'] do
    gid node['zabbix']['agent']['gid'] if node['zabbix']['agent']['gid']
    system true
  end
end

# Create conf folder
conf_dirs = [
  node['zabbix']['agent']['windows']['conf_dir'],
]
conf_dirs.each do |dir|
    directory dir do
      owner 'Administrator'
      rights :read, 'Everyone', :applies_to_children => true
      recursive true
    end
end

# Add conf template
templatePath=node['zabbix']['agent']['windows']['conf_dir'] + '\\zabbix_agentd.conf' 
template templatePath do
  source 'zabbix_agentd.win.conf.erb'
end

service 'zabbix_agentd' do
    service_name 'Zabbix Agent'
    provider Chef::Provider::Service::Windows
    supports :restart => true
    action :nothing
end

powershell_script 'restart zabbix agent' do
  code <<-EOH
    Restart-Service -displayname "Zabbix Agent"  
  EOH
end
