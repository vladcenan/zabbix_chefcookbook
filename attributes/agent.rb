#
# Cookbook Name:: zabbix
# Attributes:: agent
#
default['zabbix']['agent']['prebuild']['url']        = 'http://www.zabbix.com/downloads/2.2.14/zabbix_agents_2.2.14.linux2_6_23.amd64.tar.gz'
default['zabbix']['agent']['windows']['url']         = 'http://www.zabbix.com/downloads/2.2.0/zabbix_agents_2.2.0.win.zip'
default['zabbix']['agent']['windows']['conf_dir']    = 'C:\ProgramData\zabbix'
default['zabbix']['agent']['service_state']          = [:start, :enable]
default['zabbix']['agent']['hostname']               = node['fqdn']
default['zabbix']['agent']['include_dir']            = '/etc/zabbix/agent_include'
default['zabbix']['agent']['enable_remote_commands'] = true
default['zabbix']['agent']['listen_port']            = '10050'
default['zabbix']['agent']['timeout']                = '3'
default['zabbix']['agent']['config_file']            = '/etc/zabbix/zabbix_agentd.conf'
default['zabbix']['agent']['userparams_config_file'] = '/etc/zabbix/agent_include/user_params.conf'
default['zabbix']['agent']['groups']                 = ['chef-agent']
default['zabbix']['agent']['init_style']             = 'sysvinit'
default['zabbix']['agent']['pid_file']               = '/var/run/zabbix/zabbix_agentd.pid'
default['zabbix']['agent']['user']                   = 'zabbix'
default['zabbix']['agent']['group']                  = node['zabbix']['agent']['user']
default['zabbix']['agent']['shell']                  = node['zabbix']['shell']
default['zabbix']['agent']['log_file']               = nil
default['zabbix']['agent']['start_agents']           = nil
default['zabbix']['agent']['debug_level']            = nil
default['zabbix']['agent']['user_parameter']         = []
