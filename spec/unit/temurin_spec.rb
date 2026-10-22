require 'spec_helper'

describe 'jenkins::temurin' do
  cached(:chef_run) do
    ChefSpec::SoloRunner.new { |node| node.automatic['os_release']['version_codename'] = 'noble' }
                        .converge(described_recipe)
  end

  it 'dearmors the adoptium key as soon as it is downloaded' do
    expect(chef_run).to create_remote_file('/tmp/adoptium.asc')
    expect(chef_run.remote_file('/tmp/adoptium.asc'))
      .to notify('execute[adoptium-dearmor]').to(:run).immediately
  end

  it 'configures the adoptium apt source for the platform codename' do
    expect(chef_run).to create_file('/etc/apt/sources.list.d/adoptium.sources')
      .with_content(%r{URIs: https://packages\.adoptium\.net/artifactory/deb})
      .with_content(/Suites: noble/)
      .with_content(%r{Signed-By: /etc/apt/keyrings/adoptium\.gpg})
    expect(chef_run.file('/etc/apt/sources.list.d/adoptium.sources'))
      .to notify('apt_update[adoptium]').to(:update).immediately
  end

  it 'installs temurin 21' do
    expect(chef_run).to install_package('temurin-21-jdk')
  end
end
