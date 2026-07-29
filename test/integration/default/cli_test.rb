# Chef InSpec test for recipe jenkins::cli

describe file('/usr/local/jenkins/jars/jenkins-cli.jar') do
  it { should exist }
  it { should be_file }
end
