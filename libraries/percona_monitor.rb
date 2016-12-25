class Chef
  module Zabbix 
    class << self
    def percona(serverurl, fqdn, user, pass, port, release)
      require "zabbixapi"
      
      ostemplate='Template OS Linux'
      templatename="INFRA_PERCONA_#{release}"
      appname1='Percona'
      appname2='HealthCheck'
      itemname1="Percona Listen port #{port}"
      itemname2="Percona service: HTTP Response Check port #{port}"
      itemname3='Percona service status'
      trigname1="MySQL Port #{port} Unresponsive"
      trigname2='Percona service not responding'
      
      zbx = ZabbixApi.connect(
        :url => "#{serverurl}",
        :user => "#{user}",
        :password => "#{pass}"
      )
      
      def createhostgroup(a,zbx)
        hostgroups = zbx.hostgroups.get_full_data(:name => "#{a}")
        if hostgroups.empty?
          zbx.hostgroups.create(:name => "#{a}")
        end
      end
      
      def addtemplate(b, zbx, fqdn)
        zbx.templates.mass_add(
          :hosts_id => [zbx.hosts.get_id(:host => "#{fqdn}")],
          :templates_id => [b]
        )
      end
      
      def createtemplate(zbx,templatename,appname1,appname2,itemname1,itemname2,itemname3,trigname1,trigname2,port)
        #Create New Template
        zbx.templates.create(
          :host => "#{templatename}",
          :groups => [:groupid => zbx.hostgroups.get_id(:name => "Templates")]
        )
        #Create Application for this Template
        zbx.applications.create(
          :name => "#{appname1}",
          :hostid => zbx.templates.get_id(:host => "#{templatename}")
        )
        #Create Application for this Template
        zbx.applications.create(
          :name => "#{appname2}",
          :hostid => zbx.templates.get_id(:host => "#{templatename}")
        )
        #Create Item for this Template
        zbx.items.create(
          :name => "#{itemname1}",
          :description => "item",
          :key_ => "net.tcp.listen[#{port}]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname2}",
          :description => "item",
          :key_ => "net.tcp.service.perf[http,,#{port}]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname3}",
          :description => "item",
          :key_ => "system.run[/etc/init.d/mysql status]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        #Create Trigger for this Template     
        zbx.triggers.create(
          :description => "#{trigname1}",
          :expression => "{#{templatename}:net.tcp.listen[#{port}].last()}=0",
          :comments => "Faulty (disaster)",
          :priority => 4,
          :status => 0,
          :type => 5 
        )
        zbx.triggers.create(
          :description => "#{trigname2}",
          :expression => "{#{templatename}:system.run[/etc/init.d/mysql status].str(SUCCESS)}=0",
          :comments => "Faulty (disaster)",
          :priority => 4,
          :status => 0,
          :type => 5
        )
      end
       
      ##Check if the hostgroup for template exists and create it
      createhostgroup('RealDoc',zbx)
      
      # Check if the host is linked to a template and get the template id
      templateid = zbx.templates.get_ids_by_host( :hostids => [zbx.hosts.get_id(:host => "#{fqdn}")] )
      if templateid.empty?
        ary = zbx.templates.get_full_data(:host => "")
        if t = ary.find { |t| t['name'] == "#{templatename}" }
          tmplid = t['templateid']
          addtemplate(tmplid, zbx, fqdn)
          if t = ary.find { |t| t['name'] == "#{ostemplate}" }
            tmplid = t['templateid']
            addtemplate(tmplid, zbx, fqdn)
          end
        else
          #Method which is creating the template with all the apps and items
          createtemplate(zbx,templatename,appname1,appname2,itemname1,itemname2,itemname3,trigname1,trigname2,port)
          #Link this new created template to this Host
          ary = zbx.templates.get_full_data(:host => "")
          t = ary.find { |t| t['name'] == "#{templatename}" }
          tmplid = t['templateid']
          addtemplate(tmplid, zbx, fqdn)
          if t = ary.find { |t| t['name'] == "#{ostemplate}" }
            tmplid = t['templateid']
            addtemplate(tmplid, zbx, fqdn)
          end
        end
      else
        ary = zbx.templates.get_full_data(:host => "")
        if t = ary.find { |t| t['name'] == "#{templatename}" }
          mstmplid = t['templateid']
        else
          createtemplate(zbx,templatename,appname1,appname2,itemname1,itemname2,itemname3,trigname1,trigname2,port)
        end
        if t = ary.find { |t| t['name'] == "#{ostemplate}" }
          ostmplid = t['templateid']
        end
        if not templateid.include?(ostmplid)
          addtemplate(ostmplid, zbx, fqdn)
        end
       
        ary = zbx.templates.get_full_data(:host => "")
        if t = ary.find { |t| t['name'] == "#{templatename}" }
          mstmplid = t['templateid']
        end
        if not templateid.include?(mstmplid)
          addtemplate(mstmplid, zbx, fqdn)
        end
      end
    end
    end
  end
end
