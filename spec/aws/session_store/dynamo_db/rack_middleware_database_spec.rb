# frozen_string_literal: true

# Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require 'spec_helper'

module Aws
  module SessionStore
    module DynamoDB
      describe RackMiddleware do
        include Rack::Test::Methods

        instance_exec(&ConstantHelpers)

        before do
          @options = {}
        end

        # Table options for client
        def table_opts(sid)
          {
            table_name: Configuration::DEFAULTS[:table_name],
            key: { Configuration::DEFAULTS[:table_key] => sid }
          }
        end

        # Attributes to be retrieved via client
        def attr_opts
          {
            attributes_to_get: %w[data created_at locked_at],
            consistent_read: true
          }
        end

        def extract_time(sid)
          options = table_opts(sid).merge(attr_opts)
          Time.at((client.get_item(options)[:item]['created_at']).to_f)
        end

        let(:app) { RoutedRackApp.build(@options) }
        let(:config) { Configuration.new }
        let(:client) { config.dynamo_db_client }

        context 'Testing best case session storage', integration: true do
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
            @options[:defer] = true
            get '/'
            expect(last_response['Set-Cookie']).to be_nil
          end

          it 'expires after specified time and sets date for cookie to expire' do
            @options[:expire_after] = 1
            get '/'
            session_cookie = last_response['Set-Cookie']
            sleep(1.2)

            get '/'
            expect(last_response['Set-Cookie']).not_to be_nil
            expect(last_response['Set-Cookie']).not_to eq(session_cookie)
          end

          it 'will not set a session cookie when defer is true' do
            @options[:defer] = true
            get '/'
            expect(last_response['Set-Cookie']).to be_nil
          end
        end
      end
    end
  end
end
