require_relative './authenticator'
require_relative './base_client'
require_relative './common'
require_relative './error_response'
require_relative './error'

module PusherPlatform

  HOST_BASE = 'pusherplatform.io'

  class Instance
    def initialize(options)
      raise PusherPlatform::Error.new("No instance locator provided") if options[:locator].nil?
      raise PusherPlatform::Error.new("No key provided") if options[:key].nil?
      raise PusherPlatform::Error.new("No service name provided") if options[:service_name].nil?
      raise PusherPlatform::Error.new("No service version provided") if options[:service_version].nil?
      locator = options[:locator]
      @service_name = options[:service_name]
      @service_version = options[:service_version]

      key_parts = options[:key].match(/^([^:]+):(.+)$/)
      raise PusherPlatform::Error.new("Invalid key") if key_parts.nil?

      @key_id = key_parts[1]
      @key_secret = key_parts[2]

      split_locator = locator.split(':')

      @platform_version = split_locator[0]
      @cluster = split_locator[1]
      @instance_id = split_locator[2]

      @client = if options[:client]
        options[:client]
      else
        BaseClient.new(
          host: options[:host] || "#{@cluster}.#{HOST_BASE}",
          port: options[:port],
          instance_id: @instance_id,
          service_name: @service_name,
          service_version: @service_version
        )
      end

      @authenticator = Authenticator.new(@instance_id, @key_id, @key_secret)
    end

    def request(options)
      @client.request(options)
    end

    def authenticate(auth_payload, options)
      @authenticator.authenticate(auth_payload, options)
    end

    def authenticate_with_request(request, options)
      @authenticator.authenticate_with_request(request, options)
    end

    def authenticate_with_refresh_token(auth_payload, options)
      @authenticator.authenticate_with_refresh_token(auth_payload, options)
    end

    def authenticate_with_refresh_token_and_request(auth_payload, options)
      @authenticator.authenticate_with_refresh_token_and_request(auth_payload, options)
    end

    def generate_access_token(options)
      @authenticator.generate_access_token(options)
    end
  end
end
