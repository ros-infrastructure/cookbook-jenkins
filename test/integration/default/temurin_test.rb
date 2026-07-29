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
