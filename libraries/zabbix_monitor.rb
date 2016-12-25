class Chef
  module Zabbix
    class << self
      def monitor(zabbix_server_url, hostgroup, fqdn, ipaddress, port, user, pass)
        require 'zabbixapi'
        #Conect to Zabbix Server
        zbx = ZabbixApi.connect(
             :url => "#{zabbix_server_url}",
             :user => "#{user}",
             :password => "#{pass}"
             )
        #Create a hostgroup on zabbiz server for the VM
        def createhostgroup(a,zbx)
          hostgroups = zbx.hostgroups.get_full_data(:name => "#{a}")
          if hostgroups.empty?
            zbx.hostgroups.create(:name => "#{a}")
          end
        end
        createhostgroup("#{hostgroup}",zbx)
        #Add this VM to hostgroup created in zabbix server
        host = zbx.hosts.get_full_data(:host => "#{fqdn}")
        if host.empty?
        zbx.hosts.create(
          :host => "#{fqdn}",
          :interfaces => [
            {
             :type => 1,
             :main => 1,
             :ip => "#{ipaddress}",
             :dns => "#{fqdn}",
             :port => "#{port}",
             :useip => 1
            }
          ],
          :groups => [ :groupid => zbx.hostgroups.get_id(:name => "#{hostgroup}") ]
          )
        end
      end
    end
  end
end
