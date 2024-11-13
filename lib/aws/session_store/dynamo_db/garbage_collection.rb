# frozen_string_literal: true

require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  # Collects and deletes unwanted sessions based on
  # their creation and update dates.
  module GarbageCollection
    class << self
      # Scans DynamoDB session table to find sessions that match the max age and
      # max stale period requirements. it then deletes all of the found sessions.
      # @option (see Configuration#initialize)
      def collect_garbage(options = {})
        config = load_config(options)
        last_key = eliminate_unwanted_sessions(config)
        last_key = eliminate_unwanted_sessions(config, last_key) until last_key.empty?
      end

      private

      # Loads configuration options.
      # @option (see Configuration#initialize)
      def load_config(options = {})
        Aws::SessionStore::DynamoDB::Configuration.new(options)
      end

      # Sets scan filter attributes based on attributes specified.
      def scan_filter(config)
        hash = {}
        hash['created_at'] = oldest_date(config.max_age) if config.max_age
        hash['updated_at'] = oldest_date(config.max_stale) if config.max_stale
        { scan_filter: hash }
      end

      # Scans and deletes batch.
      def eliminate_unwanted_sessions(config, last_key = nil)
        scan_result = scan(config, last_key)
        batch_delete(config, scan_result[:items])
        scan_result[:last_evaluated_key] || {}
      end

      # Scans the table for sessions matching the max age and
      # max stale time specified.
      def scan(config, last_item = nil)
        options = scan_opts(config)
        options = options.merge(start_key(last_item)) if last_item
        config.dynamo_db_client.scan(options)
      end

      # Deletes the batch gotten from the scan result.
      def batch_delete(config, items)
        loop do
          subset = items.shift(25)
          sub_batch = write(subset)
          process!(config, sub_batch)
          break if subset.empty?
        end
      end

      # Turns array into correct format to be passed in to
      # a delete request.
      def write(sub_batch)
        sub_batch.each_with_object([]) do |item, rqst_array|
          rqst_array << { delete_request: { key: item } }
        end
      end

      # Processes pending request items.
      def process!(config, sub_batch)
        return if sub_batch.empty?

        opts = { request_items: { config.table_name => sub_batch } }
        loop do
          response = config.dynamo_db_client.batch_write_item(opts)
          opts[:request_items] = response[:unprocessed_items]
          break if opts[:request_items].empty?
        end
      end

      # Provides scan options.
      def scan_opts(config)
        table_opts(config).merge(scan_filter(config))
      end

      # Provides table options
      def table_opts(config)
        {
          table_name: config.table_name,
          attributes_to_get: [config.table_key]
        }
      end

      # Provides specified date attributes.
      def oldest_date(sec)
        {
          attribute_value_list: [n: (Time.now - sec).to_f.to_s],
          comparison_operator: 'LT'
        }
      end

      # Provides start key.
      def start_key(last_item)
        { exclusive_start_key: last_item }
      end
    end
  end
end
