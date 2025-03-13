execute 'jenkins-dearmor' do
  command "gpg -o /etc/apt/keyrings/jenkins.gpg --dearmor < /tmp/jenkins.asc"
  action :nothing
end

if node["jenkins"]["lts"]
  repository = "debian-stable"
else
  repository = "debian"
end

remote_file "/tmp/jenkins.asc" do
  source "https://pkg.jenkins.io/#{repository}/jenkins.io-2023.key"

  notifies :run, "execute[jenkins-dearmor]", :immediately
end

file "/etc/apt/sources.list.d/jenkins.sources" do
  content <<~SOURCES
  Types: deb
  URIs: https://pkg.jenkins.io/#{repository}
  Suites: binary/
  Signed-By: /etc/apt/keyrings/jenkins.gpg
  SOURCES

  notifies :update, "apt_update[jenkins]", :immediately
end

apt_update "jenkins" do
  action :nothing
end

if node.exist?('jenkins', 'master', 'java_opts')
  execute "systemctl-daemon-reload" do
    command "systemctl daemon-reload"
    action :nothing
  end

  service "jenkins" do
    action :nothing
  end

  java_opts =  node['jenkins']['master']['java_opts']
  directory '/etc/systemd/system/jenkins.service.d'
  template '/etc/systemd/system/jenkins.service.d/override.conf' do
    source 'jenkins-service-override.conf.erb'
    owner 'jenkins'
    group 'jenkins'
    variables Hash[
      java_opts: java_opts
    ]
  end
  notifies :run, "execute[systemctl-daemon-reload]", :immediately
  notifies :restart, "service[jenkins]", :delayed
end

package "jenkins"
