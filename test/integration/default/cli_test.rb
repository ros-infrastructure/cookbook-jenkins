# Chef InSpec test for recipe jenkins::cli

describe file('/usr/local/jenkins/jars/jenkins-cli.jar') do
  it { should exist }
  it { should be_file }
end

describe file('/usr/local/jenkins/jars/jenkins-cli.jar') do
  its('size') { should be > 0 }
end

# The download must be a valid jar, not an HTML error page.
describe command('jar tf /usr/local/jenkins/jars/jenkins-cli.jar') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(%r{META-INF/MANIFEST\.MF}) }
end
