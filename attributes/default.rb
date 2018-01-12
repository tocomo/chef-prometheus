#
# Cookbook Name:: prometheus
# Attributes:: default
#

default['prometheus']['cli_opts']['config.file'] = "/etc/prometheus/prometheus.yml"

default['prometheus']['rule_filenames'] = [ "/etc/prometheus/alert.rules" ]

# Location of Prometheus binary
default['prometheus']['binary'] = "/usr/local/prometheus/prometheus"

# Location of Prometheus pid file
default['prometheus']['pid'] = '/var/run/prometheus.pid'


if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 16.04
  raise 'unsupported operation system'
end

if node['platform'] == 'debian' && node['platform_version'].to_f < 8.0
  raise 'unsupported operation system'
end

if %w[rhel fedora].include? node['platform_family'] && node['platform_version'].to_f < 7.0
  raise 'unsupported operation system'
end

# rubocop:enable Style/ConditionalAssignment

# Location for Prometheus logs
default['prometheus']['log_dir'] = '/var/log/prometheus'

# Prometheus version to build
default['prometheus']['version'] = '2.0.0'

# Prometheus source repository.
default['prometheus']['git_repository'] = 'https://github.com/prometheus/prometheus.git'

# Prometheus source repository git reference. Defaults to version tag. Can
# also be set to a branch or master.
default['prometheus']['git_revision'] = "v#{node['prometheus']['version']}"

# System user to use
default['prometheus']['user'] = 'prometheus'

# System group to use
default['prometheus']['group'] = 'prometheus'

# Set if you want ot use the root user
default['prometheus']['use_existing_user'] = false

# Location for Prometheus pre-compiled binary.
# Default for testing purposes
default['prometheus']['binary_url'] =
  "https://github.com/prometheus/prometheus/releases/download/"\
  "v#{node['prometheus']['version']}/"\
  "prometheus-#{node['prometheus']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
# Default for testing purposes
default['prometheus']['checksum'] = 'e12917b25b32980daee0e9cf879d9ec197e2893924bd1574604eb0f550034d46'

# If file extension of your binary can not be determined by the URL
# then define it here. Example 'tar.bz2'
default['prometheus']['file_extension'] = ''

# Should we allow external config changes?
default['prometheus']['allow_external_config'] = false

# Prometheus job configuration chef template name.
default['prometheus']['job_config_template_name'] = 'prometheus.yml.erb'

# Prometheus custom configuration cookbook. Use this if you'd like to bypass the
# default prometheus cookbook job configuration template and implement your own
# templates and recipes to configure Prometheus jobs.
default['prometheus']['job_config_cookbook_name'] = 'prometheus'

# FLAGS Section: Any attributes defined under the flags hash will be used to
# generate the command line flags for the Prometheus executable.

# Prometheus configuration file name.

default['prometheus']['cli_flags'] = []

# Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal, panic].
default['prometheus']['cli_opts']['log.level'] = 'info'

# Alert manager HTTP API timeout.
default['prometheus']['cli_opts']['alertmanager.timeout'] = '10s'

# The capacity of the queue for pending alert manager notifications.
default['prometheus']['cli_opts']['alertmanager.notification-queue-capacity'] = 100

# Maximum number of queries executed concurrently.
default['prometheus']['cli_opts']['query.max-concurrency'] = 20



# Staleness delta allowance during expression evaluations.
#default['prometheus']['cli_opts']['query.staleness-delta'] = '5m'

# Maximum time a query may take before being aborted.
default['prometheus']['cli_opts']['query.timeout'] = '2m'

# Base path for metrics storage.
default['prometheus']['cli_opts']['storage.tsdb.path'] = '/var/lib/prometheus'

# How long to retain samples in the local storage.
default['prometheus']['cli_opts']['storage.tsdb.retention'] = '30d'

# The URL of the OpenTSDB instance to send samples to. None, if empty.
default['prometheus']['cli_opts']['storage.remote.opentsdb-url'] = ''

# Path to the console library directory.
default['prometheus']['cli_opts']['web.console.libraries'] = 'console_libraries'

# Path to the console template directory, available at /console.
default['prometheus']['cli_opts']['web.console.templates'] = 'consoles'

# The URL under which Prometheus is externally reachable (for
# example, if Prometheus is served via a reverse proxy). Used for
# generating relative and absolute links back to Prometheus itself. If
# omitted, relevant URL components will be derived automatically.
default['prometheus']['cli_opts']['web.external-url'] = "https://#{node['fqdn']}/"

# Address to listen on for the web interface, API, and telemetry.
default['prometheus']['cli_opts']['web.listen-address'] = 'localhost:9090'

# The URL of the alert manager to send notifications to.
default['prometheus']['alertmanager.url'] = 'http://127.0.0.1/alert-manager/'

# Path under which to expose metrics.
default['prometheus']['web.telemetry-path'] = '/metrics'

# Path to static asset directory, available at /user.
default['prometheus']['cli_opts']['web.user-assets'] = '/user'

# Alertmanager attributes

# Location of Alertmanager binary
default['prometheus']['alertmanager']['binary'] = '/usr/local/prometheus/alertmanager'

# Alertmanager version to fetch
default['prometheus']['alertmanager']['version'] = '0.12.0'

# Alertmanager source repository.
default['prometheus']['alertmanager']['git_repository'] = 'https://github.com/prometheus/alertmanager.git'

# Alertmanager source repository git reference. Defaults to version tag. Can
# also be set to a branch or master.
default['prometheus']['alertmanager']['git_revision'] = node['prometheus']['alertmanager']['version']

# Location for Alertmanager pre-compiled binary.
# Default for testing purposes
default['prometheus']['alertmanager']['binary_url'] =
  'https://github.com/prometheus/alertmanager/releases/download/'\
  "v#{node['prometheus']['alertmanager']['version']}/"\
  "alertmanager-#{node['prometheus']['alertmanager']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
# Default for testing purposes
default['prometheus']['alertmanager']['checksum'] = 'f5e8b30b8e0db928d294181d1648e0196a1b223fe94f044ea1a2035f893d5d53'

# If file extension of your binary can not be determined by the URL
# then define it here. Example 'tar.bz2'
default['prometheus']['alertmanager']['file_extension'] = ''

# Alertmanager configuration chef template name.
default['prometheus']['alertmanager']['config_cookbook_name'] = 'prometheus'

# Alertmanager custom configuration cookbook. Use this if you'd like to bypass the
# default prometheus cookbook Alertmanager configuration template and implement your own
# templates and recipes to configure Alertmanager.
default['prometheus']['alertmanager']['config_template_name'] = 'alertmanager.conf.erb'

# Array of alert rules filenames to be inserted in prometheus.yml.erb under "rule_files"

default['prometheus']['alertmanager']['notification'] = {}

default['prometheus']['global']['scrape_interval'] = '60s'
default['prometheus']['global']['evaluation_interval'] = '60s'
