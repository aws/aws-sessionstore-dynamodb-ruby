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
        unless sid and session = @lock.get_session_data(req.env, get_session_id_with_fallback(sid))
          session = {}
          sid = generate_unique_sid(req.env, session)
        end
        [sid, session]
      end
    end

    # Generate HMAC hash based on MD5
    def generate_hmac(sid, secret)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::MD5.new, secret, sid).strip()
    end

    def generate_unique_sid(env, session)
      env['dynamo_db.new_session'] = 'true'
      generate_sid
    end

    def get_session_id_with_fallback(sid)
      return nil unless sid
      digest, ver_sid = sid.public_id.split('--')
      if ver_sid && @config.secret_key && digest == generate_hmac(ver_sid, @config.secret_key)
        # Legacy session id format
        sid.public_id
      else
        sid.private_id
      end
    end

    def write_session(req, sid, session, options)
      sid = generate_sid if sid.nil?
      @lock.set_session_data(req.env, get_session_id_with_fallback(sid), session, options)
      sid
    end

    def delete_session(req, sid, options)
      @lock.delete_session(req.env, get_session_id_with_fallback(sid))
      generate_sid unless options[:drop]
    end
  end
end
