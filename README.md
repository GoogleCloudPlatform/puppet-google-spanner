# Google Spanner Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/google/gspanner.svg)](https://forge.puppetlabs.com/google/gspanner)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](
    #module-description)
2. [Setup - The basics of getting started with Google Spanner](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](
   #reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

This Puppet module manages the resource of Google Spanner.
You can manage its resources using standard Puppet DSL and the module will,
under the hood, ensure the state described will be reflected in the Google
Cloud Platform resources.

## Setup

To install this module on your Puppet Master (or Puppet Client/Agent), use the
Puppet module installer:

    puppet module install google-gspanner

Optionally you can install support to _all_ Google Cloud Platform products at
once by installing our "bundle" [`google-cloud`][bundle-forge] module:

    puppet module install google-cloud

## Usage

### Credentials

All Google Cloud Platform modules use an unified authentication mechanism,
provided by the [`google-gauth`][] module. Don't worry, it is automatically
installed when you install this module.

```puppet
gauth_credential { 'mycred':
  path     => $cred_path, # e.g. '/home/nelsonjr/my_account.json'
  provider => serviceaccount,
  scopes   => [
    'https://www.googleapis.com/auth/spanner.admin',
  ],
}
```

Please refer to the [`google-gauth`][] module for further requirements, i.e.
required gems.

### Examples

#### `gspanner_instance_config`

```puppet
gspanner_instance_config { 'regional-us-central1':
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### `gspanner_instance`

```puppet
gspanner_instance { 'my-spanner':
  display_name => 'My Spanner Instance',
  node_count   => 2,
  labels       => [
    {
      'cost-center' => 'ti-1700004',
    },
  ],
  config       => 'regional-us-central1',
  project      => $project, # e.g. 'my-test-project'
  credential   => 'mycred',
}

```

#### `gspanner_database`

```puppet
gspanner_database { 'webstore':
  ensure           => present,
  extra_statements => [
    'CREATE TABLE customers (
       customer_id INT64 NOT NULL,
       last_name STRING(MAX)
     ) PRIMARY KEY (customer_id)',
  ],
  instance         => 'my-spanner',
  project          => $project, # e.g. 'my-test-project'
  credential       => 'mycred',
}

```


### Classes

#### Public classes

* [`gspanner_instance_config`][]:
    A possible configuration for a Cloud Spanner instance. Configurations
    define the geographic placement of nodes and their replication.
* [`gspanner_instance`][]:
    An isolated set of Cloud Spanner resources on which databases can be
    hosted.
* [`gspanner_database`][]:
    A Cloud Spanner Database which is hosted on a Spanner instance.

### About output only properties

Some fields are output-only. It means you cannot set them because they are
provided by the Google Cloud Platform. Yet they are still useful to ensure the
value the API is assigning (or has assigned in the past) is still the value you
expect.

For example in a DNS the name servers are assigned by the Google Cloud DNS
service. Checking these values once created is useful to make sure your upstream
and/or root DNS masters are in sync.  Or if you decide to use the object ID,
e.g. the VM unique ID, for billing purposes. If the VM gets deleted and
recreated it will have a different ID, despite the name being the same. If that
detail is important to you you can verify that the ID of the object did not
change by asserting it in the manifest.

### Parameters

#### `gspanner_instance_config`

A possible configuration for a Cloud Spanner instance. Configurations
define the geographic placement of nodes and their replication.


#### Example

```puppet
gspanner_instance_config { 'regional-us-central1':
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### Reference

```puppet
gspanner_instance_config { 'id-of-resource':
  display_name => string,
  name         => string,
  project      => string,
  credential   => reference to gauth_credential,
}
```

##### `name`

  A unique identifier for the instance configuration. Values are of the
  form projects/<project>/instanceConfigs/[a-z][-a-z0-9]*


##### Output-only properties

* `display_name`: Output only.
  The name of this instance configuration as it appears in UIs.

#### `gspanner_instance`

An isolated set of Cloud Spanner resources on which databases can be
hosted.


#### Example

```puppet
gspanner_instance { 'my-spanner':
  display_name => 'My Spanner Instance',
  node_count   => 2,
  labels       => [
    {
      'cost-center' => 'ti-1700004',
    },
  ],
  config       => 'regional-us-central1',
  project      => $project, # e.g. 'my-test-project'
  credential   => 'mycred',
}

```

#### Reference

```puppet
gspanner_instance { 'id-of-resource':
  config       => reference to gspanner_instance_config,
  display_name => string,
  labels       => namevalues,
  name         => string,
  node_count   => integer,
  project      => string,
  credential   => reference to gauth_credential,
}
```

##### `name`

  A unique identifier for the instance, which cannot be changed after
  the instance is created. Values are of the form
  projects/<project>/instances/[a-z][-a-z0-9]*[a-z0-9]. The final
  segment of the name must be between 6 and 30 characters in length.

##### `config`

  A reference to the instance configuration.

##### `display_name`

Required.  The descriptive name for this instance as it appears in UIs. Must be
  unique per project and between 4 and 30 characters in length.

##### `node_count`

  The number of nodes allocated to this instance.

##### `labels`

  Cloud Labels are a flexible and lightweight mechanism for organizing
  cloud resources into groups that reflect a customer's organizational
  needs and deployment strategies. Cloud Labels can be used to filter
  collections of resources. They can be used to control how resource
  metrics are aggregated. And they can be used as arguments to policy
  management rules (e.g. route, firewall, load balancing, etc.).
  Label keys must be between 1 and 63 characters long and must conform
  to the following regular expression: `[a-z]([-a-z0-9]*[a-z0-9])?`.
  Label values must be between 0 and 63 characters long and must conform
  to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
  No more than 64 labels can be associated with a given resource.
  See https://goo.gl/xmQnxf for more information on and examples of
  labels.
  If you plan to use labels in your own code, please note that
  additional characters may be allowed in the future. And so you are
  advised to use an internal label representation, such as JSON, which
  doesn't rely upon specific characters being disallowed. For example,
  representing labels as the string: name + "_" + value would prove
  problematic if we were to allow "_" in a future release.
  An object containing a list of "key": value pairs.
  Example: { "name": "wrench", "mass": "1.3kg", "count": "3" }.


#### `gspanner_database`

A Cloud Spanner Database which is hosted on a Spanner instance.


#### Example

```puppet
gspanner_database { 'webstore':
  ensure           => present,
  extra_statements => [
    'CREATE TABLE customers (
       customer_id INT64 NOT NULL,
       last_name STRING(MAX)
     ) PRIMARY KEY (customer_id)',
  ],
  instance         => 'my-spanner',
  project          => $project, # e.g. 'my-test-project'
  credential       => 'mycred',
}

```

#### Reference

```puppet
gspanner_database { 'id-of-resource':
  extra_statements => [
    string,
    ...
  ],
  instance         => reference to gspanner_instance,
  name             => string,
  project          => string,
  credential       => reference to gauth_credential,
}
```

##### `name`

  A unique identifier for the instance, which cannot be changed after
  the instance is created. Values are of the form
  projects/<project>/instances/[a-z][-a-z0-9]*[a-z0-9]. The final
  segment of the name must be between 6 and 30 characters in length.

##### `extra_statements`

  An optional list of DDL statements to run inside the newly created
  database. Statements can create tables, indexes, etc. These statements
  execute atomically with the creation of the database: if there is an
  error in any statement, the database is not created.

##### `instance`

Required.  The instance to create the database on.



## Limitations

This module has been tested on:

* RedHat 6, 7
* CentOS 6, 7
* Debian 7, 8
* Ubuntu 12.04, 14.04, 16.04, 16.10
* SLES 11-sp4, 12-sp2
* openSUSE 13
* Windows Server 2008 R2, 2012 R2, 2012 R2 Core, 2016 R2, 2016 R2 Core

Testing on other platforms has been minimal and cannot be guaranteed.

## Development

### Automatically Generated Files

Some files in this package are automatically generated by
[Magic Modules][magic-modules].

We use a code compiler to produce this module in order to avoid repetitive tasks
and improve code quality. This means all Google Cloud Platform Puppet modules
use the same underlying authentication, logic, test generation, style checks,
etc.

Learn more about the way to change autogenerated files by reading the
[CONTRIBUTING.md][] file.

### Contributing

Contributions to this library are always welcome and highly encouraged.

See [CONTRIBUTING.md][] for more information on how to get
started.

### Running tests

This project contains tests for [rspec][], [rspec-puppet][] and [rubocop][] to
verify functionality. For detailed information on using these tools, please see
their respective documentation.

#### Testing quickstart: Ruby > 2.0.0

```
gem install bundler
bundle install
bundle exec rspec
bundle exec rubocop
```

#### Debugging Tests

In case you need to debug tests in this module you can set the following
variables to increase verbose output:

Variable                | Side Effect
------------------------|---------------------------------------------------
`PUPPET_HTTP_VERBOSE=1` | Prints network access information by Puppet provier.
`PUPPET_HTTP_DEBUG=1`   | Prints the payload of network calls being made.
`GOOGLE_HTTP_VERBOSE=1` | Prints debug related to the network calls being made.
`GOOGLE_HTTP_DEBUG=1`   | Prints the payload of network calls being made.

During test runs (using [rspec][]) you can also set:

Variable                | Side Effect
------------------------|---------------------------------------------------
`RSPEC_DEBUG=1`         | Prints debug related to the tests being run.
`RSPEC_HTTP_VERBOSE=1`  | Prints network expectations and access.

[magic-modules]: https://github.com/GoogleCloudPlatform/magic-modules
[CONTRIBUTING.md]: CONTRIBUTING.md
[bundle-forge]: https://forge.puppet.com/google/cloud
[`google-gauth`]: https://github.com/GoogleCloudPlatform/puppet-google-auth
[rspec]: http://rspec.info/
[rspec-puppet]: http://rspec-puppet.com/
[rubocop]: https://rubocop.readthedocs.io/en/latest/
[`gspanner_instance_config`]: #gspanner_instance_config
[`gspanner_instance`]: #gspanner_instance
[`gspanner_database`]: #gspanner_database
