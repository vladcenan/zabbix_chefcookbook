class Chef
  module Zabbix 
    class << self
    def rabbitmq(serverurl, fqdn, user, pass, port, port2, release)
      require "zabbixapi"
      
      ostemplate='Template OS Linux'
      templatename="INFRA_RABBITMQ_#{release}"
      appname1='RabbitMQ'
      appname2='HealthCheck'
      itemname1="RabbitMQ Port #{port}: Response Time Check (ms)"
      itemname2='RabbitMQ: Installed Version'
      itemname3="RabbitmMQ Port #{port2}: Response Time Check (ms)"
      itemname4='RabbitMQ healthcheck'
      itemname5="RabbitMQ LISTEN port #{port}"
      itemname6='RabbitMQ process count'
      itemname7='RabbitMQ process: Memory Size'
      itemname8="RabbitMQ LISTEN port #{port2}"
      trigname1='RabbitMQ HealthCheck status'
      trigname2='RabbitMQ Memory Size High'
      trigname3="RabbitMQ Port #{port} Response Slow"
      trigname4="RabbitMQ Port #{port2} Response Slow"
      
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
      
      def createtemplate(zbx,templatename,appname1,appname2,port,port2,itemname1,itemname2,itemname3,itemname4,itemname5,itemname6,itemname7,itemname8,trigname1,trigname2,trigname3,trigname4)
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
          :key_ => "net.tcp.service.perf[http,,#{port}]", 
          :type => 0,
          :value_type => 0,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname2}",
          :description => "item",
          :key_ => 'system.sw.packages[rabbit,rpm,short]',
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname3}",
          :description => "item",
          :key_ => "net.tcp.service.perf[http,,#{port2}]",
          :type => 0,
          :value_type => 0,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname2}")]
        )
        zbx.items.create(
          :name => "#{itemname4}",
          :description => "item",
          :key_ => "system.run['curl -s http://realdoc:realdoc@localhost:#{port2}/api/aliveness-test/%2F | grep { ']",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname5}",
          :description => "item",
          :key_ => "net.tcp.listen[#{port}]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname6}",
          :description => "item",
          :key_ => 'proc.num[beam.smp,,,/var/lib/rabbitmq/mnesia/rabbit]',
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname7}",
          :description => "item",
          :key_ => 'proc.mem[beam.smp,,,/var/lib/rabbitmq/mnesia/rabbit]',
          :type => 0,
          :value_type => 0,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname8}",
          :description => "item",
          :key_ => "net.tcp.listen[#{port2}]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        #Create Trigger for this Template 
        zbx.triggers.create(
         :description => "#{trigname1}",
         :expression => "{#{templatename}:system.run['curl -s http://realdoc:realdoc@localhost:#{port2}/api/aliveness-test/%2F | grep { '].str(ok)}=0",
         :comments => "Faulty (disaster)",
         :priority => 3,
         :status => 0,
         :type => 5
        )
        zbx.triggers.create(
         :description => "#{trigname2}",
         :expression => "{#{templatename}:proc.mem[beam.smp,,,/var/lib/rabbitmq/mnesia/rabbit].avg(#60)}>3221225472",
         :comments => "Faulty (disaster)",
         :priority => 3,
         :status => 0,
         :type => 5
        )
        zbx.triggers.create(
          :description => "#{trigname3}",
          :expression => "{#{templatename}:net.tcp.service.perf[http,,#{port}].avg(#5)}>25",
          :comments => "Faulty (disaster)",
          :priority => 4,
          :status => 0,
          :type => 5
        )
        zbx.triggers.create(
         :description => "#{trigname4}",
         :expression => "{#{templatename}:net.tcp.service.perf[http,,#{port2}].avg(#5)}>25",
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
          createtemplate(zbx,templatename,appname1,appname2,port,port2,itemname1,itemname2,itemname3,itemname4,itemname5,itemname6,itemname7,itemname8,trigname1,trigname2,trigname3,trigname4)
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
          createtemplate(zbx,templatename,appname1,appname2,port,port2,itemname1,itemname2,itemname3,itemname4,itemname5,itemname6,itemname7,itemname8,trigname1,trigname2,trigname3,trigname4)
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
