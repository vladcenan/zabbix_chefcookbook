#
# Cookbook Name:: rdzabbix
# Attributes:: monitor
#
default['zabbix']['monitor']['zabbix_server_url']     = nil
default['zabbix']['monitor']['zabbixapi_gem_version'] = '2.4.8'
default['zabbix']['monitor']['hostgroup']             = nil
default['zabbix']['monitor']['fqdn']                  = "#{node['fqdn']}"
default['zabbix']['monitor']['ipaddress']             = "#{node['ipaddress']}"
default['zabbix']['monitor']['port']                  = '10050'
