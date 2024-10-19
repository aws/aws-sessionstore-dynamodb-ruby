# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

describe Aws::SessionStore::DynamoDB::Configuration do
  let(:defaults) do
    Aws::SessionStore::DynamoDB::Configuration::MEMBERS.merge(
      dynamo_db_client: kind_of(Aws::DynamoDB::Client),
      error_handler: kind_of(Aws::SessionStore::DynamoDB::Errors::DefaultHandler)
    )
  end

  let(:options) do
    {
      table_name: 'SessionTable',
      table_key: 'SessionKey',
      consistent_read: false,
      read_capacity: 20,
      write_capacity: 10,
      raise_errors: true,
      max_age: 7 * 60,
      max_stale: 7,
      enable_locking: true,
      lock_expiry_time: 1000,
      lock_retry_delay: 1000,
      lock_max_wait_time: 2,
      secret_key: 'SecretKey'
    }
  end

  def setup_env
    options.each do |k, v|
      ENV["DYNAMO_DB_SESSION_#{k.to_s.upcase}"] = v.to_s
    end
  end

  def teardown_env
    options.each_key { |k| ENV.delete("DYNAMO_DB_SESSION_#{k.to_s.upcase}") }
  end

  let(:client) { Aws::DynamoDB::Client.new(stub_responses: true) }

  before do
    allow(Aws::DynamoDB::Client).to receive(:new).and_return(client)
  end

  it 'configures defaults without runtime, YAML or ENV options' do
    cfg = Aws::SessionStore::DynamoDB::Configuration.new
    expect(cfg.to_hash).to include(defaults)
  end

  it 'configures with ENV with precedence over defaults' do
    setup_env
    cfg = Aws::SessionStore::DynamoDB::Configuration.new
    expect(cfg.to_hash).to include(options)
    teardown_env
  end

  it 'configs with YAML with precedence over ENV' do
    setup_env
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      f << options.transform_keys(&:to_s).to_yaml
      f.rewind
      ENV['DYNAMO_DB_SESSION_CONFIG_FILE'] = f.path
      cfg = Aws::SessionStore::DynamoDB::Configuration.new
      ENV.delete('DYNAMO_DB_SESSION_CONFIG_FILE')
      expect(cfg.to_hash).to include(options)
    end
    teardown_env
  end

  it 'configures with runtime options with full precedence' do
    setup_env
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      f << { table_name: 'OldTable', table_key: 'OldKey' }.transform_keys(&:to_s).to_yaml
      f.rewind
      cfg = Aws::SessionStore::DynamoDB::Configuration.new(
        options.merge(
          config_file: f.path
        )
      )
      expect(cfg.to_hash).to include(options)
    end
    teardown_env
  end

  it 'raises an exception when wrong path for file' do
    config_path = 'Wrong path!'
    runtime_opts = { config_file: config_path }.merge(options)
    expect { Aws::SessionStore::DynamoDB::Configuration.new(runtime_opts) }
      .to raise_error(Errno::ENOENT)
  end
end
