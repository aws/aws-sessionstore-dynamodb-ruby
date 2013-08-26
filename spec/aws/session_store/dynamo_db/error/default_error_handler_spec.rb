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

describe AWS::SessionStore::DynamoDB do
  include Rack::Test::Methods

  instance_exec(&ConstantHelpers)

  before do
    @options = { :dynamo_db_client => client, :secret_key => 'meltingbutter' }
  end

  let(:base_app) { MultiplierApplication.new }
  let(:app) { AWS::SessionStore::DynamoDB::RackMiddleware.new(base_app, @options) }
  let(:client) { double('AWS::DynamoDB::Client') }

  context "Error handling for Rack Middleware with default error handler" do
    it "raises error for missing secret key" do
      client.stub(:update_item).and_raise(missing_key_error)
      lambda { get "/" }.should raise_error(missing_key_error)
    end

    it "catches exception for inaccurate table name and raises error " do
      client.stub(:update_item).and_raise(resource_error)
      lambda { get "/" }.should raise_error(resource_error)
    end

    it "catches exception for inaccurate table key" do
      client.stub(:update_item).and_raise(key_error)
      client.stub(:get_item).and_raise(key_error)
      get "/"
      last_request.env["rack.errors"].string.should include(key_error_msg)
    end
  end

  context "Test ExceptionHandler with true as return value for handle_error" do
    it "raises all errors" do
      @options[:raise_errors] = true
      client.stub(:update_item).and_raise(client_error)
      lambda { get "/" }.should raise_error(client_error)
    end

    it "catches exception for inaccurate table key and raises error" do
      @options[:raise_errors] = true
      client.stub(:update_item).and_raise(key_error)
      lambda { get "/" }.should raise_error(key_error)
    end
  end
end
