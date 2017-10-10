# Copyright 2017 Google Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ----------------------------------------------------------------------------
#
#     ***     AUTO GENERATED CODE    ***    AUTO GENERATED CODE     ***
#
# ----------------------------------------------------------------------------
#
#     This file is automatically generated by puppet-codegen and manual
#     changes will be clobbered when the file is regenerated.
#
#     Please read more about how to change this file in README.md and
#     CONTRIBUTING.md located at the root of this package.
#
# ----------------------------------------------------------------------------

require 'google/object_store'
require 'google/spanner/property/instanceconfig_name'
require 'google/spanner/property/integer'
require 'google/spanner/property/namevalues'
require 'google/spanner/property/string'
require 'puppet'

Puppet::Type.newtype(:gspanner_instance) do
  @doc = <<-DOC
    An isolated set of Cloud Spanner resources on which databases can be
    hosted.
  DOC

  autorequire(:gauth_credential) do
    credential = self[:credential]
    raise "#{ref}: required property 'credential' is missing" if credential.nil?
    [credential]
  end

  ensurable

  newparam :credential do
    desc <<-DESC
      A gauth_credential name to be used to authenticate with Google Cloud
      Platform.
    DESC
  end

  newparam(:project) do
    desc 'A Google Cloud Platform project to manage.'
  end

  newparam(:name, namevar: true) do
    # TODO(nelsona): Make this description to match the key of the object.
    desc 'The name of the Instance.'
  end

  newproperty(:name, parent: Google::Spanner::Property::String) do
    desc <<-DOC
      A unique identifier for the instance, which cannot be changed after the
      instance is created. Values are of the form
      projects/<project>/instances/[a-z][-a-z0-9]*[a-z0-9]. The final segment
      of the name must be between 6 and 30 characters in length. (output only)
    DOC
  end

  newproperty(:config, parent: Google::Spanner::Property::InstaConfiNameRef) do
    desc 'A reference to InstanceConfig resource'
  end

  newproperty(:display_name, parent: Google::Spanner::Property::String) do
    desc <<-DOC
      The descriptive name for this instance as it appears in UIs. Must be
      unique per project and between 4 and 30 characters in length.
    DOC
  end

  newproperty(:node_count, parent: Google::Spanner::Property::Integer) do
    desc 'The number of nodes allocated to this instance.'
  end

  newproperty(:labels, parent: Google::Spanner::Property::NameValues) do
    desc <<-DOC
      Cloud Labels are a flexible and lightweight mechanism for organizing
      cloud resources into groups that reflect a customer's organizational
      needs and deployment strategies. Cloud Labels can be used to filter
      collections of resources. They can be used to control how resource
      metrics are aggregated. And they can be used as arguments to policy
      management rules (e.g. route, firewall, load balancing, etc.). Label keys
      must be between 1 and 63 characters long and must conform to the
      following regular expression: [a-z]([-a-z0-9]*[a-z0-9])?. Label values
      must be between 0 and 63 characters long and must conform to the regular
      expression ([a-z]([-a-z0-9]*[a-z0-9])?)?. No more than 64 labels can be
      associated with a given resource. See https://goo.gl/xmQnxf for more
      information on and examples of labels. If you plan to use labels in your
      own code, please note that additional characters may be allowed in the
      future. And so you are advised to use an internal label representation,
      such as JSON, which doesn't rely upon specific characters being
      disallowed. For example, representing labels as the string: name + "_" +
      value would prove problematic if we were to allow "_" in a future
      release. An object containing a list of "key": value pairs. Example: {
      "name": "wrench", "mass": "1.3kg", "count": "3" }.
    DOC
  end

  # Returns all properties that a provider can export to other resources
  def exports
    provider.exports
  end
end
