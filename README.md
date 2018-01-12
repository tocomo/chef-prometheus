prometheus Cookbook
=====================

This cookbook installs the [Prometheus][] Version 2.X monitoring daemon using a time-series database.



Requirements
------------
- Chef 12 or higher
- Ruby 2.2 or higher

Platform
--------
Tested on

* Ubuntu 16.04
* Debian 8.9

untested but supported (that means i will fix it)
 * redhat/centos with systemd


Attributes
----------
In order to keep the README managable and in sync with the attributes, this
cookbook documents attributes inline. The usage instructions and default
values for attributes can be found in the individual attribute files.

Recipes
-------

### default
The `default` recipe installs creates all the default [Prometheus][] directories,
config files and and users.  Default also calls the configured `install_method`
recipe and finally calls the prometheus `service` recipe.


Resource/Provider
-----------------

### prometheus_job
This resource adds a job definition to the Prometheus config file.

```ruby
prometheus_job 'prometheus' do
  scrape_interval '15s'
  target "http://localhost:8080"
end
```

### prometheus_alert
This resource adds a alert definition.

```ruby
prometheus_alert 'prometheus' do
  group  'default'
  name 'broken query'
  rules {
    'response codes': {
      expr: 'rate(http_requests_total{code!='200'}[1m]) > 0',
      for: '10m',
      labels: {
        severity: 'minor'
      },
      annotations: {
        summary: 'non 200 response codes'
      },
    }
  }
end
```

Note: These cookbooks ar using the accumulator pattern so you can define multiple
prometheus_job's and they will all be added to the Prometheus config.


Dependencies
------------

The following cookbooks are dependencies:

* [apt][]
* [yum][]
* [accumulator][]
* [ark][]

## Usage

### prometheus::default

Include `prometheus` in your node's `run_list` to execute the standard deployment of prometheus:

```json
{
  "run_list": [
    "recipe[prometheus::default]"
  ]
}
```

### prometheus::use_lwrp

Used to load prometheus cookbook from wrapper cookbook.

`prometheus::use_lwrp` doesn't do anything other than allow you to include the
Prometheus cookbook into your wrapper or app cookbooks. Doing this allows you to
override prometheus attributes and use the prometheus LWRP (`prometheus_job`) in
your wrapper cookbooks.

```ruby
# Load the prometheus cookbook into your wrapper so you have access to the LWRP and attributes

include_recipe "prometheus::use_lwrp"

# Example of using search to populate prometheus.yaml jobs using the prometheus_job LWRP
# Finds all the instances that are in the current environment and are taged with "node_exporter"
# Assumes that the service instances were tagged in their own recipes.
client_servers = search(:node, "environment:#{node.chef_environment} AND tags:node_exporter")

# Assumes service_name is an attribute of each node
client_servers.each do |server|
	prometheus_job server.service_name do
 	  scrape_interval   '15s'
	  target            "#{server.fqdn}#{node['prometheus']['flags']['web.listen-address']}"
	  metrics_path       "#{node['prometheus']['web.telemetry-path']}"
	end
end

# Now run the default recipe that does all the work configuring and deploying prometheus
include_recipe 'prometheus::default'
```

Development
-----------
Please see the [Contributing](CONTRIBUTING.md) and [Issue Reporting](ISSUES.md) Guidelines.

License & Authors
------

- Author: Ray Rodriguez <rayrod2030@gmail.com>
- Author: kristian järvenpää <kristian.jarvenpaa@gmail.com>
- Author: Tobias Strauß <tac@gmx.li>

```text
Licensed under the Apache License, Version 2.0 (the “License”);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[apt]: https://github.com/opscode-cookbooks/apt
[Prometheus]: https://github.com/prometheus/prometheus
[ark]: https://github.com/burtlo/ark
[yum]: https://github.com/chef-cookbooks/yum
[accumulator]: https://github.com/kisoku/chef-accumulator
