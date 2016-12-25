#
# Cookbook Name:: rdzabbix
# Recipe:: default
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'rdzabbix::_provider_gem'
include_recipe 'rdzabbix::agent'
