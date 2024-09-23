execute "adoptium-dearmor" do
  command "gpg -o /etc/apt/keyrings/adoptium.gpg --dearmor < /tmp/adoptium.asc"
  action :nothing
end

remote_file "/tmp/adoptium.asc" do
  source "https://packages.adoptium.net/artifactory/api/gpg/key/public"

  notifies :run, "execute[adoptium-dearmor]", :immediately
end

apt_update "adoptium" do
  action :nothing
end

file '/etc/apt/sources.list.d/adoptium.sources' do
  content <<~EOF
  Types: deb
  URIs: https://packages.adoptium.net/artifactory/deb
  Suites: #{node["os_release"]["version_codename"]}
  Components: main
  Signed-By: /etc/apt/keyrings/adoptium.gpg
  EOF

  notifies :update, "apt_update[adoptium]", :immediately
end

package 'temurin-21-jdk'
