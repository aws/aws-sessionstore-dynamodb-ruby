module Aws::SessionStore::DynamoDB::Locking
  # This class provides a framework for implementing
  # locking strategies.
  class Base

    # Creates configuration object.
    def initialize(cfg)
      @config = cfg
    end

    # Updates session in database
    def set_session_data(env, sid, session, options = {})
      return false if session.empty?
      packed_session = pack_data(session)
      handle_error(env) do
        if env['dynamo_db.new_session']
          save_options = save_new_opts(env, sid, packed_session)
          @config.dynamo_db_client.put_item(save_options)
          env.delete('dynamo_db.new_session')
        else
          save_options = save_exists_opts(env, sid, packed_session, options)
          @config.dynamo_db_client.update_item(save_options)
        end
        sid
      end
    end

    # Packs session data.
    def pack_data(data)
      [Marshal.dump(data)].pack("m*")
    end

    # Gets session data.
    def get_session_data(env, sid)
      raise NotImplementedError
    end

    # Deletes session based on id
    def delete_session(env, sid)
      handle_error(env) do
        @config.dynamo_db_client.delete_item(delete_opts(sid))
      end
    end

    # Each database operation is placed in this rescue wrapper.
    # This wrapper will call the method, rescue any exceptions and then pass
    # exceptions to the configured error handler.
    def handle_error(env = nil, &block)
      begin
        yield
      rescue Aws::DynamoDB::Errors::ServiceError => e
        @config.error_handler.handle_error(e, env)
      end
    end

    private

    # @return [Hash] Options for deleting session.
    def delete_opts(sid)
      {
        table_name: @config.table_name,
        key: {
          @config.table_key => sid
        }
      }
    end

    # @return [Hash] Options for saving a new session in database.
    def save_new_opts(env, sid, session)
      {
        table_name: @config.table_name,
        item: {
           @config.table_key => sid,
           data: session.to_s,
           created_at: created_at,
           updated_at: updated_at,
           expire_at: expire_at
        },
        condition_expression: "attribute_not_exists(#{@config.table_key})"
      }
    end

    # @return [Hash] Options for saving an existing sesison in the database.
    def save_exists_opts(env, sid, session, options = {})
      data = if data_unchanged?(env, session)
        {}
      else
        {
          data: {
            value: session.to_s,
            action: 'PUT'
          }
        }
      end
      {
        table_name: @config.table_name,
        key: {
          @config.table_key => sid
        },
        attribute_updates: {
          updated_at: {
            value: updated_at,
            action: 'PUT'
          },
          expire_at: {
            value: expire_at,
            action: 'PUT'
          }
        }.merge(data),
        return_values: 'UPDATED_NEW'
      }
    end

    # Unmarshal the data.
    def unpack_data(packed_data)
      Marshal.load(packed_data.unpack("m*").first)
    end

    def updated_at
      Time.now.to_f
    end

    def created_at
      updated_at
    end

    def expire_at
      max_stale = @config.max_stale || 0
      (Time.now + max_stale).to_i
    end

    # Determine if data has been manipulated
    def data_unchanged?(env, session)
      return false unless env['rack.initial_data']
      env['rack.initial_data'] == session
    end
  end
end
