# @file local_config.rb
#
# Project Clearwater - IMS in the Cloud
# Copyright (C) 2015  Metaswitch Networks Ltd
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version, along with the "Special Exception" for use of
# the program along with SSL, set forth below. This program is distributed
# in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details. You should have received a copy of the GNU General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
# The author can be reached by email at clearwater@metaswitch.com or by
# post at Metaswitch Networks Ltd, 100 Church St, Enfield EN2 6BQ, UK
#
# Special Exception
# Metaswitch Networks Ltd  grants you permission to copy, modify,
# propagate, and distribute a work formed by combining OpenSSL with The
# Software, or a work derivative of such a combination, even if such
# copying, modification, propagation, or distribution would otherwise
# violate the terms of the GPL. You must comply with the GPL in all
# respects for all of the code used other than OpenSSL.
# "OpenSSL" means OpenSSL toolkit software distributed by the OpenSSL
# Project and licensed under the OpenSSL Licenses, or a work based on such
# software and licensed under the OpenSSL Licenses.
# "OpenSSL Licenses" means the OpenSSL License and Original SSLeay License
# under which the OpenSSL Project distributes the OpenSSL toolkit software,
# as those licenses appear in the file LICENSE-OPENSSL.

# Setup the clearwater local config file
directory "/etc/clearwater" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# Set up the local config file

# Determine GR site names
if node[:clearwater][:gr]
  if node[:clearwater][:index] and node[:clearwater][:index] % 2 == 1
    local_site = "odd_numbers"
    remote_site = "even_numbers"
  else
    local_site = "even_numbers"
    remote_site = "odd_numbers"
  end
else
  local_site = "single_site"
  remote_site = ""
end

# Find all nodes in the deployment that have been marked as part of the etcd cluster.
nodes = search(:node, "chef_environment:#{node.chef_environment}")
etcd = nodes.find_all { |s| s[:clearwater] && s[:clearwater][:etcd_cluster] }

if node[:clearwater][:split_storage]
  etcd_cluster_or_proxy = "etcd_proxy"
else
  etcd_cluster_or_proxy = "etcd_cluster"
end

# Create local_config
template "/etc/clearwater/local_config" do
    mode "0644"
    source "local_config.erb"
    variables node: node,
              etcd_cluster_or_proxy: etcd_cluster_or_proxy,
              etcd: etcd,
              local_site: local_site,
              remote_site: remote_site
end
