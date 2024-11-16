# frozen_string_literal: true

require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  # This class provides a Configuration object for all DynamoDB session store operations
  # by pulling configuration options from Runtime, the ENV, a YAML file, and default
  # settings, in that order.
  #
  # # Environment Variables
  # The Configuration object can load default values from your environment. All configuration
  # keys are supported except for `:dynamo_db_client` and `:error_handler`. The keys take the form
  # of AWS_DYNAMO_DB_SESSION_<KEY_NAME>. Example:
  #
  #     export AWS_DYNAMO_DB_SESSION_TABLE_NAME='Sessions'
  #     export AWS_DYNAMO_DB_SESSION_TABLE_KEY='id'
  #
  # # Locking Strategy
  # By default, locking is disabled for session store access. To enable locking, set the
  # `:enable_locking` option to true. The locking strategy is pessimistic, meaning that only one
  # read can be made on a session at once. While the session is being read by the process with the
  # lock, other processes may try to obtain a lock on the same session but will be blocked.
  # See the initializer for how to configure the pessimistic locking strategy to your needs.
  #
  # # Handling Errors
  # There are two configurable options for error handling: `:raise_errors` and `:error_handler`.
  #
  # If you would like to use the Default Error Handler, you can decide to set `:raise_errors`
  # to true or false depending on whether you want all errors, regardless of class, to be raised
  # up the stack and essentially throw a 500.
  #
  # If you decide to use your own Error Handler, you must implement the `BaseErrorHandler`
  # class and pass it into the `:error_handler` option.
  # @see BaseHandler Interface for Error Handling for DynamoDB Session Store.
  #
  # # DynamoDB Specific Options
  # You may configure the table name and table hash key value of your session table with
  # the `:table_name` and `:table_key` options. You may also configure performance options for
  # your table with the `:consistent_read`, `:read_capacity`, `:write_capacity`. For more information
  # about these configurations see
  # {https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html#create_table-instance_method CreateTable}
  # method for Amazon DynamoDB.
  #
  class Configuration
    # @api private
    MEMBERS = {
      table_name: 'sessions',
      table_key: 'session_id',
      secret_key: nil,
      consistent_read: true,
      read_capacity: 10,
      write_capacity: 5,
      raise_errors: false,
      error_handler: nil,
      max_age: nil,
      max_stale: nil,
      enable_locking: false,
      lock_expiry_time: 500,
      lock_retry_delay: 500,
      lock_max_wait_time: 1,
      config_file: nil,
      dynamo_db_client: nil
    }.freeze

    # Provides configuration object that allows access to options defined
    # during Runtime, in the ENV, in a YAML file, and by default.
    #
    # @option options [String] :table_name ("sessions") Name of the session table.
    # @option options [String] :table_key ("session_id") The hash key of the session table.
    # @option options [String] :secret_key Secret key for HMAC encryption.
    # @option options [Boolean] :consistent_read (true) If true, a strongly consistent read is used.
    #   If false, an eventually consistent read is used.
    #   @see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadConsistency.html
    # @option options [Integer] :read_capacity (10) The maximum number of strongly consistent reads
    #   consumed per second before DynamoDB raises a ThrottlingException.
    #   @see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/read-write-operations.html
    # @option options [Integer] :write_capacity (5) The maximum number of writes
    #   consumed per second before DynamoDB returns a ThrottlingException.
    #   @see https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/read-write-operations.html
    # @option options [Boolean] :raise_errors (false) If true, all errors are raised up the stack
    #   when default ErrorHandler. If false, Only specified errors are raised up the stack when
    #   the default ErrorHandler is used.
    # @option options [#handle_error] :error_handler (Errors::DefaultHandler) An error handling object
    #   that handles all exceptions thrown during execution of the rack application.
    # @option options [Integer] :max_age (nil) Maximum number of seconds earlier
    #   from the current time that a session was created.
    # @option options [Integer] :max_stale (nil) Maximum number of seconds
    #   before current time that session was last accessed.
    # @option options [Integer] :enable_locking (false) If true, a pessimistic locking strategy will be
    #   used for all session accesses.
    # @option options [Integer] :lock_expiry_time (500) Time in milliseconds after which the lock
    #   expires on session.
    # @option options [Integer] :lock_retry_delay (500) Time in milliseconds to wait before retrying
    #   to obtain lock once an attempt to obtain the lock has been made and has failed.
    # @option options [Integer] :lock_max_wait_time (500) Maximum time in seconds to wait to acquire the
    #   lock before giving up.
    # @option options [String, Pathname] :config_file
    #   Path to a YAML file that contains configuration options.
    # @option options [Aws::DynamoDB::Client] :dynamo_db_client (Aws::DynamoDB::Client.new)
    #   DynamoDB client used to perform database operations inside of the rack application.
    def initialize(options = {})
      opts = options
      opts = env_options.merge(opts)
      opts = file_options(opts).merge(opts)
      MEMBERS.each_pair do |opt_name, default_value|
        opts[opt_name] = default_value unless opts.key?(opt_name)
      end
      opts = opts.merge(dynamo_db_client: default_dynamo_db_client(opts))
      opts = opts.merge(error_handler: default_error_handler(opts)) unless opts[:error_handler]

      set_attributes(opts)
    end

    MEMBERS.each_key do |attr_name|
      attr_reader(attr_name)
    end

    # @return [Hash] The merged configuration hash.
    def to_hash
      MEMBERS.each_with_object({}) do |(key, _), hash|
        hash[key] = send(key)
      end
    end

    private

    def default_dynamo_db_client(options)
      dynamo_db_client = options[:dynamo_db_client] || Aws::DynamoDB::Client.new
      dynamo_db_client.config.user_agent_frameworks << 'aws-sessionstore-dynamodb'
      dynamo_db_client
    end

    def default_error_handler(options)
      Aws::SessionStore::DynamoDB::Errors::DefaultHandler.new(options[:raise_errors])
    end

    # @return [Hash] Environment options.
    def env_options
      unsupported_keys = %i[dynamo_db_client error_handler]
      (MEMBERS.keys - unsupported_keys).each_with_object({}) do |opt_name, opts|
        key = env_key(opt_name)
        next unless ENV.key?(key)

        opts[opt_name] = parse_env_value(key)
      end
    end

    def env_key(opt_name)
      # legacy - remove this in aws-sessionstore-dynamodb ~> 4
      key = "DYNAMO_DB_SESSION_#{opt_name.to_s.upcase}"
      if ENV.key?(key)
        Kernel.warn("The environment variable `#{key}` is deprecated.
                     Please use `AWS_DYNAMO_DB_SESSION_#{opt_name.to_s.upcase}` instead.")
      else
        key = "AWS_DYNAMO_DB_SESSION_#{opt_name.to_s.upcase}"
      end
      key
    end

    def parse_env_value(key)
      val = ENV.fetch(key, nil)
      Integer(val)
    rescue ArgumentError
      %w[true false].include?(val) ? val == 'true' : val
    end

    # @return [Hash] File options.
    def file_options(options = {})
      if options[:config_file]
        load_from_file(options[:config_file])
      else
        {}
      end
    end

    # Load options from the YAML file.
    def load_from_file(file_path)
      require 'erb'
      require 'yaml'
      opts = YAML.safe_load(ERB.new(File.read(file_path)).result) || {}
      unsupported_keys = %i[dynamo_db_client error_handler config_file]
      opts.transform_keys(&:to_sym).reject { |k, _| unsupported_keys.include?(k) }
    end

    def set_attributes(options)
      MEMBERS.each_key do |attr_name|
        instance_variable_set("@#{attr_name}", options[attr_name])
      end
    end
  end
end
