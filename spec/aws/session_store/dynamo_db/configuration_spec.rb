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

require "spec_helper"

describe AWS::SessionStore::DynamoDB::Configuration do

  let(:defaults) do
    {
      :table_name => "sessions",
      :table_key => "session_id",
      :consistent_read => true,
      :read_capacity => 10,
      :write_capacity => 5,
      :raise_errors => false
    }
  end

  let(:expected_file_opts) do
    {
      :consistent_read => true,
      :AWS_ACCESS_KEY_ID => 'FakeKey',
      :AWS_REGION => 'New York',
      :table_name => 'NewTable',
      :table_key => 'Somekey',
      :AWS_SECRET_ACCESS_KEY => 'Secret'
    }
  end

  let(:runtime_options) do
    {
      :table_name => "SessionTable",
      :table_key => "session_id_stuff"
    }
  end

  def expected_options(opts)
    cfg = AWS::SessionStore::DynamoDB::Configuration.new(opts)
    expected_opts = defaults.merge(expected_file_opts).merge(opts)
    cfg.to_hash.should include(expected_opts)
  end

  context "Configuration Tests" do
    it "configures option with out runtime,YAML or ENV options" do
      cfg = AWS::SessionStore::DynamoDB::Configuration.new
      cfg.to_hash.should include(defaults)
    end

    it "configures accurate option hash with runtime options, no YAML or ENV" do
      cfg = AWS::SessionStore::DynamoDB::Configuration.new(runtime_options)
      expected_opts = defaults.merge(runtime_options)
      cfg.to_hash.should include(expected_opts)
    end

    it "merge YAML and runtime options giving runtime precendence" do
      config_path = File.dirname(__FILE__) + '/app_config.yml'
      runtime_opts = {:config_file => config_path}.merge(runtime_options)
      expected_options(runtime_opts)
    end

    it "loads options from YAML file based on Rails environment" do
      rails = double('Rails', {:env => 'test', :root => ''})
      stub_const("Rails", rails)
      config_path = File.dirname(__FILE__) + '/rails_app_config.yml'
      runtime_opts = {:config_file => config_path}.merge(runtime_options)
      expected_options(runtime_opts)
    end

    it "has rails defiend but no file specified, no error thrown" do
      rails = double('Rails', {:env => 'test', :root => ''})
      stub_const("Rails", rails)
      cfg = AWS::SessionStore::DynamoDB::Configuration.new(runtime_options)
      expected_opts = defaults.merge(runtime_options)
      cfg.to_hash.should include(expected_opts)
    end

    it "has rails defiend but and default rails YAML file loads" do
      rails = double('Rails', {:env => 'test', :root => File.dirname(__FILE__)})
      stub_const("Rails", rails)
      cfg = AWS::SessionStore::DynamoDB::Configuration.new(runtime_options)
      expected_opts = defaults.merge(runtime_options)
      cfg.to_hash.should include(expected_opts)
    end

    it "throws an exception when wrong path for file" do
      config_path = 'Wrong path!'
      runtime_opts = {:config_file => config_path}.merge(runtime_options)
      expect{cfg = AWS::SessionStore::DynamoDB::Configuration.new(runtime_opts)}.to raise_error(Errno::ENOENT)
    end
  end
end
