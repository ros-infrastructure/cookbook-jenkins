# InSpec tests for the jenkins cookbook needrestart integration.

describe file('/usr/local/bin/jenkins-safe-restart') do
  it { should be_file }
  it { should be_executable }
  it { should be_owned_by 'root' }
  its('content') { should match(/safe-restart/) }
  its('content') { should_not match(/reboot/) }
end

describe file('/etc/needrestart/restart.d/jenkins.service') do
  it { should be_file }
  it { should be_executable }
  it { should be_owned_by 'root' }
  its('content') { should match(/systemd-run/) }
  its('content') { should match(/OnCalendar|--on-calendar="\*-\*-\* 03:00:00"/) }
end

# The hook must arm exactly one timer, even when invoked repeatedly.
describe 'needrestart hook' do
  2.times do
    describe command('/etc/needrestart/restart.d/jenkins.service') do
      its('exit_status') { should eq 0 }
    end
  end

  describe command('systemctl list-timers --all --no-legend jenkins-deferred-maintenance.timer') do
    its('exit_status') { should eq 0 }
    its('stdout.lines.count') { should eq 1 }
    its('stdout') { should match(/jenkins-deferred-maintenance\.service/) }
  end
end
