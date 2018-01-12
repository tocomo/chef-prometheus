#
# Filename:: alertmanager_spec.rb
# Description:: Verifies alertmanager recipe(s).
#
# Author: Elijah Caine <elijah.caine.mv@gmail.com>
#

require 'spec_helper'

# Caution: This is a carbon-copy of default_spec.rb with some variable replacements.

# rubocop:disable Metrics/BlockLength
describe 'prometheus::alertmanager' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/tmp/chef/cache').converge(described_recipe)
  end

  before do
    stub_command('/usr/local/go/bin/go version | grep "go1.5 "').and_return(0)
  end

  it 'creates a user with correct attributes' do
    expect(chef_run).to create_user('prometheus').with(
      system: true,
      shell: '/bin/false',
      home: '/var/lib/prometheus'
    )
  end

  it 'creates a directory at /etc/prometheus' do
    expect(chef_run).to create_directory('/etc/prometheus').with(
      owner: 'root',
      group: 'root',
      mode: '0755',
      recursive: true
    )
  end

  it 'creates a directory at /var/log/prometheus' do
    expect(chef_run).to create_directory('/var/log/prometheus').with(
      owner: 'prometheus',
      group: 'prometheus',
      mode: '0755',
      recursive: true
    )
  end

  it 'renders a prometheus job configuration file and notifies prometheus to restart' do
    resource = chef_run.template('/etc/prometheus/alertmanager.conf')
    expect(resource).to notify('service[alertmanager]').to(:restart)
  end

  # Test for binary.rb

  context 'binary' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['alertmanager']['version'] = '0.12.0'
        node.set['prometheus']['alertmanager']['install_method'] = 'binary'
      end.converge(described_recipe)
  end

  it 'runs ark with correct attributes' do
    expect(chef_run).to put_ark('prometheus').with(
      url: 'https://github.com/prometheus/alertmanager/releases/download/v0.12.0/alertmanager-0.12.0.linux-amd64.tar.gz',
      checksum: '8b796592b974a1aa51cac4e087071794989ecc957d4e90025d437b4f7cad214a',
      version: '0.12.0',
    )
  end

  it 'runs ark with given file_extension' do
    chef_run.node.set['prometheus']['alertmanager']['file_extension'] = 'tar.gz'
    chef_run.converge(described_recipe)
    expect(chef_run).to put_ark('prometheus').with(
      extension: 'tar.gz'
    )
  end

  context 'systemd' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['init_style'] = 'systemd'
        node.set['prometheus']['alertmanager']['install_method'] = 'binary'
      end.converge(described_recipe)
    end

    it 'renders a systemd service file' do
      expect(chef_run).to render_file('/etc/systemd/system/alertmanager.service')
    end
  end

end
