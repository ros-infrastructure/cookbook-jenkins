# Chef InSpec test for the non-default attribute paths, converged together in
# one suite to avoid reinstalling Jenkins for each:
#   node['jenkins']['lts'] = false                 -> non-LTS apt repository
#   node['jenkins']['jenkins_java_opts']           -> systemd override.conf
#   node['jenkins']['plugin_manager_version']      -> plugin manager download

describe file('/etc/apt/sources.list.d/jenkins.list') do
  its('content') { should match(%r{https://pkg\.jenkins\.io/debian binary/}) }
  its('content') { should_not match(/debian-stable/) }
end

describe file('/etc/systemd/system/jenkins.service.d/override.conf') do
  it { should exist }
  its('content') { should match(/-Xmx512m -Xms512m/) }
end

describe command('systemctl show jenkins --property=Environment') do
  its('stdout') { should match(/-Xmx512m -Xms512m/) }
end

describe service('jenkins') do
  it { should be_enabled }
  it { should be_running }
end

describe file('/usr/local/jenkins/jars/jenkins-plugin-manager.jar') do
  it { should exist }
  its('owner') { should eq 'jenkins' }
  its('mode') { should cmp '0644' }
end

describe command('java -jar /usr/local/jenkins/jars/jenkins-plugin-manager.jar --version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/2\.12\.15/) }
end
