# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'logger'

module Aws::SessionStore::DynamoDB
  # This module provides a way to create and delete a session table.
  module Table
    class << self
      # Creates a session table.
      # @option (see Configuration#initialize)
      def create_table(options = {})
        config = load_config(options)
        config.dynamo_db_client.create_table(create_opts(config))
        logger.info "Table #{config.table_name} created, waiting for activation..."
        config.dynamo_db_client.wait_until(:table_exists, table_name: config.table_name)
        logger.info "Table #{config.table_name} is now ready to use."
      rescue Aws::DynamoDB::Errors::ResourceInUseException
        logger.warn "Table #{config.table_name} already exists, skipping creation."
      end

      # Deletes a session table.
      # @option (see Configuration#initialize)
      def delete_table(options = {})
        config = load_config(options)
        config.dynamo_db_client.delete_table(table_name: config.table_name)
        config.dynamo_db_client.wait_until(:table_not_exists, table_name: config.table_name)
        logger.info "Table #{config.table_name} deleted."
      end

      private

      def logger
        @logger ||= Logger.new($stdout)
      end

      # Loads configuration options.
      # @option (see Configuration#initialize)
      def load_config(options = {})
        Aws::SessionStore::DynamoDB::Configuration.new(options)
      end

      def create_opts(config)
        properties(config.table_name, config.table_key).merge(
          throughput(config.read_capacity, config.write_capacity)
        )
      end

      # @return Properties for the session table.
      def properties(table_name, hash_key)
        attributes(hash_key).merge(schema(table_name, hash_key))
      end

      # @return [Hash] Attribute settings for creating the session table.
      def attributes(hash_key)
        {
          attribute_definitions: [
            { attribute_name: hash_key, attribute_type: 'S' }
          ]
        }
      end

      # @return Schema values for the session table.
      def schema(table_name, hash_key)
        {
          table_name: table_name,
          key_schema: [{ attribute_name: hash_key, key_type: 'HASH' }]
        }
      end

      # @return Throughput for the session table.
      def throughput(read, write)
        {
          provisioned_throughput: {
            read_capacity_units: read,
            write_capacity_units: write
          }
        }
      end
    end
  end
end
