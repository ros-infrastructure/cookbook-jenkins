directory "/usr/local/jenkins/jars" do
  recursive true
  owner "jenkins"
  group "jenkins"
end

remote_file "/usr/local/jenkins/jars/jenkins-plugin-manager.jar" do
  source "https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/#{node["jenkins"]["plugin_manager_version"]}/jenkins-plugin-manager-#{node["jenkins"]["plugin_manager_version"]}.jar"
  owner "jenkins"
  group "jenkins"
  mode "0644"
end
