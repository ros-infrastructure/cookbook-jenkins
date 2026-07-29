# Chef InSpec test for recipe jenkins::jenkins

describe file('/etc/apt/keyrings/jenkins-keyring.asc') do
  it { should exist }
  its('mode') { should cmp '0644' }
  its('owner') { should eq 'root' }
end

describe file('/etc/apt/sources.list.d/jenkins.list') do
  it { should exist }
  # node['jenkins']['lts'] defaults to true, which points at the
  # debian-stable repository.
  its('content') { should match(%r{https://pkg\.jenkins\.io/debian-stable binary/}) }
end

describe package('jenkins') do
  it { should be_installed }
end

describe service('jenkins') do
  it { should be_enabled }
  it { should be_running }
end
