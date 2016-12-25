class Chef
  module Zabbix 
    class << self
    def microservice(serverurl, fqdn, user, pass, port, release, service)
      require "zabbixapi"
      
      ostemplate='Template OS Linux'
      templatename="MS_#{service.upcase}_#{release}"
      appname1="#{service}"
      appname2='HealthCheck'
      itemname1="#{service} LISTEN Port #{port}"
      itemname2="#{service} process"
      itemname3="#{service} service: Response Time Check (s)"
      itemname4="#{service} service: HTTP Response Check"
      itemname5="#{service} process: Memory Size"
      itemname6="#{service} Healthcheck"
      itemname7="#{service} Healthcheck Ping"
      trigname1="#{service} HealthCheck False Detected"
      trigname2="#{service} Healthcheck Response Time too high"
      trigname3="#{service} Healthcheck Status"
      trigname4="#{service} Ping Healthcheck Status"
      trigname5="#{service} Port ChecK #{port}"
      
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
      
      def createtemplate(zbx,templatename,appname1,appname2,port,service,itemname1,itemname2,itemname3,itemname4,itemname5,itemname6,itemname7,trigname1,trigname2,trigname3,trigname4,trigname5)
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
          :key_ => "proc.num[java,,,#{service}.jar]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname3}",
          :description => "item",
          :key_ => "web.page.perf[localhost,healthcheck,#{port}]",
          :type => 0,
          :value_type => 0,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname4}",
          :description => "item",
          :key_ => "net.tcp.service[http,,#{port}]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname5}",
          :description => "item",
          :key_ => "proc.mem[java,,,#{service}.jar]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname1}")]
        )
        zbx.items.create(
          :name => "#{itemname6}",
          :description => "item",
          :key_ => "web.page.regexp[localhost,healthcheck,#{port},\{.*]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname2}")]
        )
        zbx.items.create(
          :name => "#{itemname7}",
          :description => "item",
          :key_ => "web.page.regexp[localhost,ping,#{port},\pong]",
          :type => 0,
          :value_type => 4,
          :hostid => zbx.templates.get_id(:host => "#{templatename}"),
          :applications => [zbx.applications.get_id(:name => "#{appname2}")]
        )
        #Create Trigger for this Template
        zbx.triggers.create(
          :description => "#{trigname1}",
          :expression => "{#{templatename}:web.page.regexp[localhost,healthcheck,#{port},\{.*].str('true')}=0 and {#{templatename}:web.page.regexp[localhost,healthcheck,#{port},\{.*].change(0)}=0",
          :comments => "Faulty (disaster)",
          :priority => 2,
          :status => 0,
          :type => 5
        )
        zbx.triggers.create(
          :description => "#{trigname2}",
          :expression => "{#{templatename}:web.page.perf[localhost,healthcheck,#{port}].max(120)}>30",
          :comments => "Faulty (disaster)",
          :priority => 2,
          :status => 0,
          :type => 5
        )
        zbx.triggers.create(
          :description => "#{trigname3}",
          :expression => "{#{templatename}:web.page.regexp[localhost,healthcheck,#{port},\{.*].str('true')}=0 and {#{templatename}:web.page.regexp[localhost,healthcheck,#{port},\{.*].change(0)}=0",
          :comments => "Faulty (disaster)",
          :priority => 3,
          :status => 0,
          :type => 5
        )
        zbx.triggers.create(
          :description => "#{trigname4}",
          :expression => "{#{templatename}:web.page.regexp[localhost,ping,#{port},\pong].str(pong)}=0",
          :comments => "Faulty (disaster)",
          :priority => 3,
          :status => 0,
          :type => 5
        )
        zbx.triggers.create(
          :description => "#{trigname5}",
          :expression => "{#{templatename}:net.tcp.listen[#{port}].last()}=0",
          :comments => "Faulty (disaster)",
          :priority => 2,
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
          createtemplate(zbx,templatename,appname1,appname2,port,service,itemname1,itemname2,itemname3,itemname4,itemname5,itemname6,itemname7,trigname1,trigname2,trigname3,trigname4,trigname5)
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
          createtemplate(zbx,templatename,appname1,appname2,port,service,itemname1,itemname2,itemname3,itemname4,itemname5,itemname6,itemname7,trigname1,trigname2,trigname3,trigname4,trigname5)
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
