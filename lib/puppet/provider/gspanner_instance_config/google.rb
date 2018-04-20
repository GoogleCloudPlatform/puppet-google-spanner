# Copyright 2018 Google Inc.
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
#     This file is automatically generated by Magic Modules and manual
#     changes will be clobbered when the file is regenerated.
#
#     Please read more about how to change this file in README.md and
#     CONTRIBUTING.md located at the root of this package.
#
# ----------------------------------------------------------------------------

require 'google/hash_utils'
require 'google/object_store'
require 'google/spanner/network/delete'
require 'google/spanner/network/get'
require 'google/spanner/network/post'
require 'google/spanner/network/put'
require 'google/spanner/property/string'
require 'puppet'

Puppet::Type.type(:gspanner_instance_config).provide(:google) do
  mk_resource_methods

  def self.instances
    debug('instances')
    raise [
      '"puppet resource" is not supported at the moment:',
      'TODO(nelsonjr): https://goto.google.com/graphite-bugs-view?id=167'
    ].join(' ')
  end

  def self.prefetch(resources)
    debug('prefetch')
    resources.each do |name, resource|
      project = resource[:project]
      debug("prefetch #{name}") if project.nil?
      debug("prefetch #{name} @ #{project}") unless project.nil?
      fetch = fetch_resource(resource, self_link(resource))
      resource.provider = present(name, fetch) unless fetch.nil?
      Google::ObjectStore.instance.add(:gspanner_instance_config, resource)
    end
  end

  def self.present(name, fetch)
    result = new({ title: name, ensure: :present }.merge(fetch_to_hash(fetch)))
    result.instance_variable_set(:@fetched, fetch)
    result
  end

  def self.fetch_to_hash(fetch)
    {
      name: Google::Spanner::Property::String.api_munge(fetch['name']),
      display_name:
        Google::Spanner::Property::String.api_munge(fetch['displayName'])
    }.reject { |_, v| v.nil? }
  end

  def flush
    debug('flush')
    # return on !@dirty is for aiding testing (puppet already guarantees that)
    return if @created || @deleted || !@dirty
    update_req = Google::Spanner::Network::Put.new(self_link(@resource),
                                                   fetch_auth(@resource),
                                                   'application/json',
                                                   resource_to_request)
    return_if_object update_req.send
  end

  def dirty(field, from, to)
    @dirty = {} if @dirty.nil?
    @dirty[field] = {
      from: from,
      to: to
    }
  end

  def exports
    {
      name: @fetched['name']
    }
  end

  private

  def self.resource_to_hash(resource)
    {
      project: resource[:project],
      name: resource[:name],
      display_name: resource[:display_name]
    }.reject { |_, v| v.nil? }
  end

  def resource_to_request
    request = {
      name: @resource[:name]
    }.reject { |_, v| v.nil? }
    # Format request to conform with API endpoint
    request = encode_request(request)
    debug "request: #{request}" unless ENV['PUPPET_HTTP_DEBUG'].nil?
    request.to_json
  end

  def fetch_auth(resource)
    self.class.fetch_auth(resource)
  end

  def self.fetch_auth(resource)
    Puppet::Type.type(:gauth_credential).fetch(resource)
  end

  def debug(message)
    puts("DEBUG: #{message}") if ENV['PUPPET_HTTP_VERBOSE']
    super(message)
  end

  def self.collection(data)
    URI.join(
      'https://spanner.googleapis.com/v1/',
      expand_variables(
        'projects/{{project}}/instanceConfigs',
        data
      ).split('/').map { |p| p.gsub('%3A', ':') }
                  .join('/')
    )
  end

  def collection(data)
    self.class.collection(data)
  end

  def self.self_link(data)
    URI.join(
      'https://spanner.googleapis.com/v1/',
      expand_variables(
        'projects/{{project}}/instanceConfigs/{{name}}',
        data
      ).split('/').map { |p| p.gsub('%3A', ':') }
                  .join('/')
    )
  end

  def self_link(data)
    self.class.self_link(data)
  end

  def self.return_if_object(response)
    raise "Bad response: #{response.body}" \
      if response.is_a?(Net::HTTPBadRequest)
    raise "Bad response: #{response}" \
      unless response.is_a?(Net::HTTPResponse)
    return if response.is_a?(Net::HTTPNotFound)
    return if response.is_a?(Net::HTTPNoContent)
    result = decode_response(response)
    raise_if_errors result, %w[error errors], 'message'
    raise "Bad response: #{response}" unless response.is_a?(Net::HTTPOK)
    result
  end

  def return_if_object(response)
    self.class.return_if_object(response)
  end

  def self.extract_variables(template)
    template.scan(/{{[^}]*}}/).map { |v| v.gsub(/{{([^}]*)}}/, '\1') }
            .map(&:to_sym)
  end

  def self.expand_variables(template, var_data, extra_data = {})
    data = if var_data.class <= Hash
             var_data.merge(extra_data)
           else
             resource_to_hash(var_data).merge(extra_data)
           end
    extract_variables(template).each do |v|
      unless data.key?(v)
        raise "Missing variable :#{v} in #{data} on #{caller.join("\n")}}"
      end
      template.gsub!(/{{#{v}}}/, CGI.escape(data[v].to_s))
    end
    template
  end

  def encode_request(request)
    request['name'] =
      "projects/#{resource[:project]}/instanceConfigs/#{resource[:name]}"
    request.to_json
  end

  def self.decode_response(response)
    response = JSON.parse(response.body)
    response['name'] = response['name'].split('/').last
    response
  end

  def decode_response(response)
    self.class.decode_response(response)
  end

  def self.fetch_resource(resource, self_link)
    get_request = ::Google::Spanner::Network::Get.new(
      self_link, fetch_auth(resource)
    )
    return_if_object get_request.send
  end

  def self.raise_if_errors(response, err_path, msg_field)
    errors = ::Google::HashUtils.navigate(response, err_path)
    raise_error(errors, msg_field) unless errors.nil?
  end

  def self.raise_error(errors, msg_field)
    raise IOError, ['Operation failed:',
                    errors.map { |e| e[msg_field] }.join(', ')].join(' ')
  end
end
