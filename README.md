rdzabbix Cookbook
=================
TODO: Enter the cookbook description here.

This cookbook handle zabbix agent in linux and windows environments.
It also configure and add host to zabbix server (which will be get from the environemnt, and credentials from an rdzabbix data bag)
You can use libraries to to generate the temaplte for a java microservice (microservice_monitor library), percona, rabbitmq, redis and mongod and link these to host.

Requirements
------------
TODO: List your cookbook requirements. Be sure to include any requirements this cookbook has on platforms, libraries, other cookbooks, packages, operating systems, etc.

e.g.
#### packages
- `toaster` - rdzabbix needs toaster to brown your bagel.

Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### rdzabbix::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['rdzabbix']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### rdzabbix::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `rdzabbix` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[rdzabbix]"
  ]
}
```

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: vladhc@yahoo.com 
# zabbix_chefcookbook
