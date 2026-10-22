# Chef InSpec test for recipe jenkins::plugin_manager

describe directory('/usr/local/jenkins/jars') do
  it { should exist }
  its('owner') { should eq 'jenkins' }
  its('group') { should eq 'jenkins' }
end

describe file('/usr/local/jenkins/jars/jenkins-plugin-manager.jar') do
  it { should exist }
  it { should be_file }
  its('owner') { should eq 'jenkins' }
  its('group') { should eq 'jenkins' }
  its('mode') { should cmp '0644' }
end
