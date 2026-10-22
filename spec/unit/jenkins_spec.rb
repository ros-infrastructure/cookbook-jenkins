require 'spec_helper'

describe 'jenkins::jenkins' do
  context 'with default attributes' do
    cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'uses the LTS repository' do
      expect(chef_run).to create_file('/etc/apt/sources.list.d/jenkins.list')
        .with_content(%r{https://pkg\.jenkins\.io/debian-stable binary/})
      expect(chef_run).to create_remote_file('/etc/apt/keyrings/jenkins-keyring.asc')
        .with(source: 'https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key', mode: '0644')
    end

    it 'updates apt when the sources list changes' do
      expect(chef_run.file('/etc/apt/sources.list.d/jenkins.list'))
        .to notify('apt_update[jenkins]').to(:update).immediately
    end

    it 'installs jenkins without a pinned version' do
      expect(chef_run).to install_package('jenkins').with(version: nil)
    end

    it 'enables the service and starts it at the end of the run' do
      expect(chef_run).to enable_service('jenkins')
      expect(chef_run).to_not render_file('/etc/systemd/system/jenkins.service.d/override.conf')
    end
  end

  context 'with lts disabled' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new { |node| node.override['jenkins']['lts'] = false }
                          .converge(described_recipe)
    end

    it 'uses the weekly repository' do
      expect(chef_run).to create_file('/etc/apt/sources.list.d/jenkins.list')
        .with_content(%r{https://pkg\.jenkins\.io/debian binary/})
      expect(chef_run).to create_remote_file('/etc/apt/keyrings/jenkins-keyring.asc')
        .with(source: 'https://pkg.jenkins.io/debian/jenkins.io-2026.key')
    end
  end

  context 'with jenkins_java_opts set' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new { |node| node.override['jenkins']['jenkins_java_opts'] = '-Xmx512m' }
                          .converge(described_recipe)
    end

    it 'renders the systemd override' do
      expect(chef_run).to create_directory('/etc/systemd/system/jenkins.service.d')
      expect(chef_run).to render_file('/etc/systemd/system/jenkins.service.d/override.conf')
        .with_content(/JAVA_OPTS=-Xmx512m/)
    end

    it 'reloads systemd immediately and restarts jenkins later' do
      template = chef_run.template('/etc/systemd/system/jenkins.service.d/override.conf')
      expect(template).to notify('execute[systemctl-daemon-reload]').to(:run).immediately
      expect(template).to notify('service[jenkins]').to(:restart).delayed
    end
  end

  context 'with the legacy master java_opts attribute' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new { |node| node.override['jenkins']['master']['java_opts'] = '-Xmx256m' }
                          .converge(described_recipe)
    end

    it 'migrates it to jenkins_java_opts' do
      expect(chef_run.node['jenkins']['jenkins_java_opts']).to eq('-Xmx256m')
      expect(chef_run).to render_file('/etc/systemd/system/jenkins.service.d/override.conf')
        .with_content(/-Xmx256m/)
    end
  end

  context 'with both java opts attributes set and differing' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.override['jenkins']['master']['java_opts'] = '-Xmx256m'
        node.override['jenkins']['jenkins_java_opts'] = '-Xmx512m'
      end.converge(described_recipe)
    end

    it 'prefers the new attribute' do
      expect(chef_run).to render_file('/etc/systemd/system/jenkins.service.d/override.conf')
        .with_content(/-Xmx512m/)
    end
  end

  context 'with a pinned version' do
    let(:pinned) { '2.401.3' }

    def run_with(installed)
      ChefSpec::SoloRunner.new do |node|
        node.override['jenkins']['master']['version'] = pinned
        node.automatic['packages']['jenkins'] = { 'version' => installed } if installed
      end.converge(described_recipe)
    end

    it 'installs the pinned version when jenkins is not installed' do
      expect(run_with(nil)).to install_package('jenkins').with(version: pinned)
    end

    it 'upgrades from an older installed version' do
      expect(run_with('2.300.1-1')).to install_package('jenkins').with(version: pinned)
    end

    it 'accepts the same version with a Debian revision suffix' do
      expect(run_with('2.401.3-1')).to install_package('jenkins').with(version: pinned)
    end

    it 'refuses to downgrade' do
      expect { run_with('2.555.1-1') }.to raise_error(RuntimeError)
    end
  end
end
