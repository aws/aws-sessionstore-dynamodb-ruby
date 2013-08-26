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

module AWS
  module SessionStore
    module DynamoDB
      describe RackMiddleware do
        include Rack::Test::Methods

        before { @options = {} }

        def ensure_data_updated(mutated_data)
          dynamo_db_client.should_receive(:update_item) do |options|
            if mutated_data
              options[:attribute_updates]["data"].should_not be_nil
            else
              options[:attribute_updates]["data"].should be_nil
            end
          end
        end

        before do
          @options = {
            :dynamo_db_client => dynamo_db_client,
            :secret_key => 'watermelon_cherries'
          }
        end

        let(:base_app) { MultiplierApplication.new }
        let(:app) { RackMiddleware.new(base_app, @options) }

        let(:sample_packed_data) do
          [Marshal.dump("multiplier" => 1)].pack("m*")
        end

        let(:dynamo_db_client) do
          client = double('AWS::DynamoDB::Client')
          client.stub(:delete_item) { 'Deleted' }
          client.stub(:list_tables) { {:table_names => ['Sessions']} }
          client.stub(:get_item) do
            { :item => { 'data' => { :s => sample_packed_data } } }
          end
          client.stub(:update_item) do
            { :attributes => { :created_at => 'now' } }
          end
          client
        end

        context "Testing best case session storage with mock client" do
          it "stores session data in session object" do
            get "/"
            last_request.session.to_hash.should eq("multiplier" => 1)
          end

          it "creates a new HTTP cookie when Cookie not supplied" do
            get "/"
            last_response.body.should eq('All good!')
            last_response['Set-Cookie'].should be_true
          end

          it "loads/manipulates a session based on id from HTTP-Cookie" do
            get "/"
            last_request.session.to_hash.should eq("multiplier" => 1)

            get "/"
            last_request.session.to_hash.should eq("multiplier" => 2)
          end

          it "does not rewrite Cookie if cookie previously/accuarately set" do
            get "/"
            last_response['Set-Cookie'].should_not be_nil

            get "/"
            last_response['Set-Cookie'].should be_nil
          end

          it "does not set cookie when defer option is specifed" do
            @options[:defer] = true
            get "/"
            last_response['Set-Cookie'].should eq(nil)
          end

          it "creates new sessopm with false/nonexistant http-cookie id" do
            get "/"
            last_response['Set-Cookie'].should_not eq('1234')
            last_response['Set-Cookie'].should_not be_nil
          end

          it "expires after specified time and sets date for cookie to expire" do
            @options[:expire_after] = 0
            get "/"
            session_cookie = last_response['Set-Cookie']

            get "/"
            last_response['Set-Cookie'].should_not be_nil
            last_response['Set-Cookie'].should_not eq(session_cookie)
          end

          it "doesn't reset Cookie if not outside expire date" do
            @options[:expire_after] = 3600
            get "/"
            session_cookie = last_response['Set-Cookie']
            get "/"
            last_response['Set-Cookie'].should eq(session_cookie)
          end

          it "will not set a session cookie when defer is true" do
            @options[:defer] = true
            get "/"
            last_response['Set-Cookie'].should eq(nil)
          end

          it "generates sid and migrates data to new sid when renew is selected" do
            @options[:renew] = true
            get "/"
            last_request.session.to_hash.should eq("multiplier" => 1)
            session_cookie = last_response['Set-Cookie']

            get "/" , "HTTP_Cookie" => session_cookie
            last_response['Set-Cookie'].should_not eq(session_cookie)
            last_request.session.to_hash.should eq("multiplier" => 2)
            session_cookie = last_response['Set-Cookie']
          end

          it "doesn't resend unmutated data" do
            ensure_data_updated(true)
            @options[:renew] = true
            get "/"

            ensure_data_updated(false)
            get "/", {}, { "rack.session" => { "multiplier" => nil } }
          end
        end
      end
    end
  end
end
