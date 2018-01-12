require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'prometheus::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/tmp/chef/cache').converge(described_recipe)
  end

  it 'creates a user with correct attributes' do
    expect(chef_run).to create_user('prometheus').with(
      system: true,
      shell: '/bin/false',
      home: '/usr/local/prometheus'
    )
  end

  it 'creates a directory at /etc/prometheus' do
    expect(chef_run).to create_directory('/etc/prometheus').with(
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

  it 'creates a directory at /var/lib/prometheus' do
    expect(chef_run).to create_directory('/var/lib/prometheus').with(
      owner: 'prometheus',
      group: 'prometheus',
      mode: '0755',
      recursive: true
    )
  end

  it 'renders a prometheus job configuration file and notifies prometheus to reload' do
    resource = chef_run.template('/etc/prometheus/prometheus.yml')
    expect(resource).to notify('service[prometheus]').to(:reload)
  end

  # Test for source.rb


  # Test for binary.rb

  context 'binary' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['version'] = '2.0.0'
        node.set['prometheus']['install_method'] = 'binary'
      end.converge(described_recipe)
    end

    it 'runs ark with correct attributes' do
      expect(chef_run).to put_ark('prometheus').with(
        url: 'https://github.com/prometheus/prometheus/releases/download/v2.0.0/prometheus-2.0.0.linux-amd64.tar.gz',
        checksum: 'bb4e3bf4c9cd2b30fc922e48ab584845739ed4aa50dea717ac76a56951e31b98',
        version: '2.0.0',
        path: '/usr/local/prometheus'
      )
    end

    it 'runs ark with given file_extension' do
      chef_run.node.set['prometheus']['file_extension'] = 'tar.gz'
      chef_run.converge(described_recipe)
      expect(chef_run).to put_ark('prometheus').with(
        extension: 'tar.gz'
      )
    end


    context 'systemd' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'systemd'
          node.set['prometheus']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders a systemd service file' do
        expect(chef_run).to render_file('/etc/systemd/system/prometheus.service')
      end
    end

  end
end
