require 'spec_helper'

describe 'jenkins::plugin_manager' do
  context 'with default attributes' do
    cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'creates the jars directory owned by jenkins' do
      expect(chef_run).to create_directory('/usr/local/jenkins/jars')
        .with(recursive: true, owner: 'jenkins', group: 'jenkins')
    end

    it 'downloads the default plugin manager release' do
      expect(chef_run).to create_remote_file('/usr/local/jenkins/jars/jenkins-plugin-manager.jar')
        .with(
          source: 'https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar',
          owner: 'jenkins', group: 'jenkins', mode: '0644'
        )
    end
  end

  context 'with a custom plugin_manager_version' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new { |node| node.override['jenkins']['plugin_manager_version'] = '2.12.15' }
                          .converge(described_recipe)
    end

    it 'downloads that release' do
      expect(chef_run).to create_remote_file('/usr/local/jenkins/jars/jenkins-plugin-manager.jar')
        .with_source(['https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.15/jenkins-plugin-manager-2.12.15.jar'])
    end
  end
end
