# Chef InSpec test for recipe jenkins::temurin

describe file('/etc/apt/keyrings/adoptium.gpg') do
  it { should exist }
end

describe file('/etc/apt/sources.list.d/adoptium.sources') do
  it { should exist }
  its('content') { should match(%r{URIs: https://packages\.adoptium\.net/artifactory/deb}) }
  its('content') { should match(%r{Signed-By: /etc/apt/keyrings/adoptium\.gpg}) }
end

describe package('temurin-21-jdk') do
  it { should be_installed }
end

describe command('java -version 2>&1') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/Temurin|openjdk version "21/i) }
end
