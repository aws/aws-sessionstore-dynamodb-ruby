module Aws::SessionStore::DynamoDB::Locking
  # This class gets and sets sessions
  # without a locking strategy.
  class Null < Aws::SessionStore::DynamoDB::Locking::Base
    # Retrieve session if it exists from the database by id.
    # Unpack the data once retrieved from the database.
    def get_session_data(env, sid)
      handle_error(env) do
        result = @config.dynamo_db_client.get_item(get_session_opts(sid))
        extract_data(env, result)
      end
    end

    # @return [Hash] Options for getting session.
    def get_session_opts(sid)
      {
        table_name: @config.table_name,
        key: {
          @config.table_key => sid
        },
        attributes_to_get: [ "data" ],
        consistent_read: @config.consistent_read
      }
    end

    # @return [String] Session data.
    def extract_data(env, result = nil)
      if result[:item] && result[:item].has_key?("data")
        env['rack.initial_data'] = result[:item]["data"]
        unpack_data(result[:item]["data"])
      else
        nil
      end
    end

  end
end
