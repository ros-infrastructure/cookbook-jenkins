require 'spec_helper'

describe 'jenkins::cli' do
  def converge_with(running, *recipes)
    allow_any_instance_of(Chef::Recipe).to receive(:system)
      .with('systemctl is-active --quiet jenkins').and_return(running)
    ChefSpec::SoloRunner.converge(*recipes, described_recipe)
  end

  context 'when jenkins is already running' do
    it 'downloads the cli jar right away' do
      expect(converge_with(true)).to create_if_missing_remote_file('/usr/local/jenkins/jars/jenkins-cli.jar')
        .with(source: 'http://localhost:8080/jnlpJars/jenkins-cli.jar', retries: 3, retry_delay: 5)
    end
  end

  context 'when jenkins is not running' do
    # jenkins::jenkins is included so that service[jenkins] exists to subscribe to.
    let(:chef_run) { converge_with(false, 'jenkins::jenkins') }

    it 'does nothing by default' do
      expect(chef_run).to nothing_remote_file('/usr/local/jenkins/jars/jenkins-cli.jar')
    end

    it 'waits for the jenkins service to be (re)started' do
      resource = chef_run.remote_file('/usr/local/jenkins/jars/jenkins-cli.jar')
      expect(resource).to subscribe_to('service[jenkins]').on(:create).delayed
    end
  end
end
