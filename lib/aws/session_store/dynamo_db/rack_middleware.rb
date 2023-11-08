require 'action_dispatch/middleware/session/abstract_store'
require 'openssl'
require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  class RackMiddleware < ActionDispatch::Session::AbstractSecureStore
    attr_reader :config

    def initialize(app, options = {})
      super
      @config = Configuration.new(options)
      set_locking_strategy
    end

    private

    def set_locking_strategy
      @lock = Aws::SessionStore::DynamoDB::Locking::Null.new(@config)
    end

    # Gets session data.
    def find_session(req, sid)
      if req.session.options[:skip]
        [generate_sid, {}]
      else
        unless sid and session = @lock.get_session_data(req.env, sid.private_id)
          session = {}
          sid = generate_unique_sid(req.env, session)
        end
        [sid, session]
      end
    end

    def generate_unique_sid(env, session)
      env['dynamo_db.new_session'] = 'true'
      generate_sid
    end

    def write_session(req, sid, session, options)
      @lock.set_session_data(req.env, sid.private_id, session, options)
      sid
    end

    def delete_session(req, sid, options)
      @lock.delete_session(req.env, sid.private_id)
      generate_sid unless options[:drop]
    end
  end
end
