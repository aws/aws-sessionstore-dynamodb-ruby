# frozen_string_literal: true

require 'spec_helper'

module Aws
  module SessionStore
    module DynamoDB
      describe RackMiddleware, integration: true do
        include Rack::Test::Methods

        def table_opts(sid)
          {
            table_name: config.table_name,
            key: { config.table_key => sid }
          }
        end

        def attr_opts
          {
            attributes_to_get: %w[data created_at],
            consistent_read: true
          }
        end

        def extract_time(sid)
          options = table_opts(sid).merge(attr_opts)
          Time.at((config.dynamo_db_client.get_item(options)[:item]['created_at']).to_f)
        end

        let(:options) do
          { table_name: 'sessionstore-integration-test', secret_key: 'watermelon_cherries' }
        end

        let(:base_app) { MultiplierApplication.new }
        let(:app) { RackMiddleware.new(base_app, options) }
        let(:config) { app.config }

        it 'stores session data in session object' do
          get '/'
          expect(last_request.session[:multiplier]).to eq(1)
        end

        it 'creates a new HTTP cookie when Cookie not supplied' do
          get '/'
          expect(last_response.body).to eq('All good!')
          expect(last_response['Set-Cookie']).to be_truthy
        end

        it 'does not rewrite Cookie if cookie previously/accuarately set' do
          get '/'
          expect(last_response['Set-Cookie']).not_to be_nil

          get '/'
          expect(last_response['Set-Cookie']).to be_nil
        end

        it 'does not set cookie when defer option is specified' do
          options[:defer] = true
          get '/'
          expect(last_response['Set-Cookie']).to be_nil
        end

        it 'creates new session with false/nonexistant http-cookie id' do
          env = {
            'HTTP_COOKIE' => 'rack.session=ApplePieBlueberries',
            'rack.session' => { 'multiplier' => 1 }
          }
          get '/', {}, env
          expect(last_response['Set-Cookie']).not_to eq('rack.session=ApplePieBlueberries')
          expect(last_response['Set-Cookie']).not_to be_nil
        end

        it 'expires after specified time and sets date for cookie to expire' do
          options[:expire_after] = 1
          get '/'
          session_cookie = last_response['Set-Cookie']
          sleep(1.2)

          get '/'
          expect(last_response['Set-Cookie']).not_to be_nil
          expect(last_response['Set-Cookie']).not_to eq(session_cookie)
        end

        it 'will not set a session cookie when defer is true' do
          options[:defer] = true
          get '/'
          expect(last_response['Set-Cookie']).to be_nil
        end

        it 'adds the created at attribute for a new session' do
          get '/'
          expect(last_request.env['dynamo_db.new_session']).to eq('true')
          sid = last_response['Set-Cookie'].split(/[;=]/)[1]
          time = extract_time(sid)
          expect(time).to be_within(2).of(Time.now)

          get '/'
          expect(last_request.env['dynamo_db.new_session']).to be_nil
        end
      end
    end
  end
end
