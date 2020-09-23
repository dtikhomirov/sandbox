template "/etc/selinux/config" do
  source "selinux_config.erb"
  mode '0644'
  owner 'root'
  group 'root'
end

execute "Disable SELinux enforcement at runtime" do
  user 'root'
  cwd '/tmp'
  command 'setenforce 0'
  returns [0 ,1]
  action :run
end

execute "Configure firewalld policies" do
  user 'root'
  cwd '/tmp'
  command 'firewall-cmd --add-port=3000/tcp --add-port=7000/tcp --permanent && firewall-cmd --reload'
  action :run
end

execute "Disable swap" do
  user 'root'
  cwd '/tmp'
  command 'swapoff -a'
  action :run
end

execute "Swithe NPM to version 12" do
  user 'root'
  cwd '/tmp'
  command "yum -y remove nodejs; yum -y module reset nodejs; yum -y module enable nodejs:12"
  action :run
end

package node['backstage']['package']['node'] do
  action :install
end

template "/etc/yum.repos.d/yarn.repo" do
  source "yarn.erb"
  mode '0644'
  owner 'root'
  group 'root'
end

package node['backstage']['package']['yarn'] do
	action :install
end

package node['backstage']['package']['git'] do
	action :install
end

execute "Clones backstage repo" do
  user 'root'
  cwd '/opt'
  command "git clone #{node['backstage']['git']['repo']}"
  action :run
end

execute "Install backstage dependencies" do
  user 'root'
  cwd '/opt/backstage'
  command 'yarn install'
  action :run
end

execute "Install backstage dependencies" do
  user 'root'
  cwd '/opt/backstage'
  command 'yarn tsc'
  action :run
end

execute "Install backstage dependencies" do
  user 'root'
  cwd '/opt/backstage'
  command 'yarn build'
  action :run
end