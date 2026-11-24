# Chef InSpec test for recipe jenkins::jenkins with the legacy
# node['jenkins']['master']['java_opts'] attribute set (and the new
# node['jenkins']['jenkins_java_opts'] left unset).
#
# Covers the sous-chefs/jenkins attribute migration branch: the recipe should
# copy the legacy value onto the new attribute and render the systemd
# override with it, which is otherwise untested by the `default` suite.

describe file('/etc/systemd/system/jenkins.service.d/override.conf') do
  it { should exist }
  its('content') { should match(/-Xmx256m/) }
end

describe service('jenkins') do
  it { should be_enabled }
  it { should be_running }
end
