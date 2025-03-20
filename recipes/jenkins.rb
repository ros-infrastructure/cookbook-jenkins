execute 'jenkins-dearmor' do
  command "gpg --batch --no-tty -o /etc/apt/keyrings/jenkins.gpg --dearmor < /tmp/jenkins.asc"
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

# Migrate from attributes used by sous-chefs/jenkins
# The expected attributes have been changed but in order to remain compatible
# with configurations from the prior cookbook a warning is being added if the
# old attributes are set and differ from the new ones.
if node.exist?('jenkins', 'master', 'java_opts')
  if !node.exist?('jenkins', 'jenkins_java_opts')
      Chef::Log.warn(
        "The attribute `node['jenkins']['master']['java_opts']` is now `node['jenkins']['jenkins_java_opts']`. " +
        "Support for the previous attribute may be removed in a future release of this cookbook. " +
        "Replacing the `node['jenkins']['master']['java_opts']` attribute with `node['jenkins']['jenkins_java_opts']` is recommended."
      )
      node.default['jenkins']['jenkins_java_opts'] = node['jenkins']['master']['java_opts']
  elsif node['jenkins']['jenkins_java_opts'] != node['jenkins']['master']['java_opts']
      Chef::Log.warn(
        "Both `node['jenkins']['master']['java_opts']` and `node['jenkins']['jenkins_java_opts']` are defined but differ. " +
        "The `node['jenkins']['jenkins_java_opts']` attribute will be used. " +
        "Support for the previous attribute may be removed in a future release of this cookbook. " +
        "Removing the `node['jenkins']['master']['java_opts']` attribute is recommended."
      )
  end
end

package "jenkins"

if node.exist?('jenkins', 'jenkins_java_opts')
  execute "systemctl-daemon-reload" do
    command "systemctl daemon-reload"
    action :nothing
  end

  java_opts =  node['jenkins']['jenkins_java_opts']
  directory '/etc/systemd/system/jenkins.service.d'
  template '/etc/systemd/system/jenkins.service.d/override.conf' do
    source 'jenkins-service-override.conf.erb'
    variables Hash[
      java_opts: java_opts
    ]
    notifies :run, "execute[systemctl-daemon-reload]", :immediately
    notifies :restart, "service[jenkins]", :delayed
  end
end

service 'jenkins' do
  action [:enable, :start]
end
