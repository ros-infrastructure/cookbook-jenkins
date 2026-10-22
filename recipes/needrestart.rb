# Defers needrestart-triggered Jenkins restarts to a maintenance window and
# performs them as a Jenkins safe restart. Requires jenkins::cli for the CLI jar.
package "needrestart"

directory "/etc/needrestart/restart.d" do
  recursive true
  owner "root"
  group "root"
  mode "0755"
end

template "/usr/local/bin/jenkins-safe-restart" do
  source "jenkins-safe-restart.sh.erb"
  owner "root"
  group "root"
  mode "0755"
  variables Hash[
    url: node["jenkins"]["needrestart"]["url"],
    auth_file: node["jenkins"]["needrestart"]["auth_file"]
  ]
end

# needrestart runs restart.d/<service> in place of `systemctl restart <service>`
# when invoked in automatic mode (`$nrconf{restart} = 'a'`).
template "/etc/needrestart/restart.d/jenkins.service" do
  source "needrestart-jenkins.service.erb"
  owner "root"
  group "root"
  mode "0755"
  variables Hash[
    calendar: node["jenkins"]["needrestart"]["calendar"]
  ]
end
