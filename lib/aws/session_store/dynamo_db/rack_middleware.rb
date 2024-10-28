# frozen_string_literal: true

require 'rack/session/abstract/id'
require 'openssl'
require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  # This class is an ID based Session Store Rack Middleware
  # that uses a DynamoDB backend for session storage.
  class RackMiddleware < Rack::Session::Abstract::Persisted
    # Initializes SessionStore middleware.
    #
    # @param app Rack application.
    # @option (see Configuration#initialize)
    # @raise [Aws::DynamoDB::Errors::ResourceNotFoundException] If a valid table name is not provided.
    # @raise [Aws::SessionStore::DynamoDB::MissingSecretKey] If a secret key is not provided.
    def initialize(app, options = {})
      super
      @config = Configuration.new(options)
      validate_config
      set_locking_strategy
    end

    # Get session from the database or create a new session.
    #
    # @raise [Aws::SessionStore::DynamoDB::Errors::LockWaitTimeoutError] If the session
    #   has waited too long to obtain lock.
    def find_session(req, sid)
      case verify_hmac(sid)
      when nil
        set_new_session_properties(req.env)
      when false
        handle_error { raise Errors::InvalidIDError }
        set_new_session_properties(req.env)
      else
        data = @lock.get_session_data(req.env, sid)
        [sid, data || {}]
      end
    end

    # Sets the session in the database after packing data.
    #
    # @return [Hash] If session has been saved.
    # @return [false] If session has could not be saved.
    def write_session(req, sid, session, options)
      @lock.set_session_data(req.env, sid, session, options)
    end

    # Destroys session and removes session from database.
    #
    # @return [String] return a new session id or nil if options[:drop]
    def delete_session(req, sid, options)
      @lock.delete_session(req.env, sid)
      generate_sid unless options[:drop]
    end

    # @return [Configuration] An instance of Configuration that is used for
    #   this middleware.
    attr_reader :config

    private

    def set_locking_strategy
      @lock =
        if @config.enable_locking
          Aws::SessionStore::DynamoDB::Locking::Pessimistic.new(@config)
        else
          Aws::SessionStore::DynamoDB::Locking::Null.new(@config)
        end
    end

    def validate_config
      raise Errors::MissingSecretKeyError unless @config.secret_key
    end

    # Sets new session properties.
    def set_new_session_properties(env)
      env['dynamo_db.new_session'] = 'true'
      [generate_sid, {}]
    end

    # Each database operation is placed in this rescue wrapper.
    # This wrapper will call the method, rescue any exceptions and then pass
    # exceptions to the configured session handler.
    def handle_error(env = nil)
      yield
    rescue Aws::DynamoDB::Errors::Base,
           Aws::SessionStore::DynamoDB::Errors::InvalidIDError => e
      @config.error_handler.handle_error(e, env)
    end

    # Generate HMAC hash based on MD5
    def generate_hmac(sid, secret)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('MD5'), secret, sid).strip
    end

    # Generate sid with HMAC hash
    def generate_sid(secure = @sid_secure)
      sid = super
      "#{generate_hmac(sid, @config.secret_key)}--" + sid
    end

    # Verify digest of HMACed hash
    #
    # @return [true] If the HMAC id has been verified.
    # @return [false] If the HMAC id has been corrupted.
    def verify_hmac(sid)
      return unless sid

      digest, ver_sid = sid.split('--')
      return false unless ver_sid

      digest == generate_hmac(ver_sid, @config.secret_key)
    end
  end
end
