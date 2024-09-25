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

package "jenkins"
