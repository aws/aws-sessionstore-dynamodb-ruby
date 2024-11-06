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
      secret_key: 'SecretKey'
    }
  end

  def setup_env(options)
    options.each do |k, v|
      ENV["DYNAMO_DB_SESSION_#{k.to_s.upcase}"] = v.to_s
    end
  end

  def teardown_env(options)
    options.each_key { |k| ENV.delete("DYNAMO_DB_SESSION_#{k.to_s.upcase}") }
  end

  let(:client) { Aws::DynamoDB::Client.new(stub_responses: true) }

  before do
    allow(Aws::DynamoDB::Client).to receive(:new).and_return(client)
  end

  it 'configures defaults without runtime, ENV, or YAML options' do
    cfg = Aws::SessionStore::DynamoDB::Configuration.new
    expect(cfg.to_hash).to include(defaults)
  end

  it 'configures with YAML with precedence over defaults' do
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      f << options.transform_keys(&:to_s).to_yaml
      f.rewind
      cfg = Aws::SessionStore::DynamoDB::Configuration.new(config_file: f.path)
      expect(cfg.to_hash).to include(options)
    end
  end

  it 'configs with ENV with precedence over YAML' do
    setup_env(options)
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      f << { table_name: 'OldTable', table_key: 'OldKey' }.transform_keys(&:to_s).to_yaml
      f.rewind
      cfg = Aws::SessionStore::DynamoDB::Configuration.new(config_file: f.path)
      expect(cfg.to_hash).to include(options)
    ensure
      teardown_env(options)
    end
  end

  it 'configures in code with full precedence' do
    old = { table_name: 'OldTable', table_key: 'OldKey' }
    setup_env(options.merge(old))
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      f << old.transform_keys(&:to_s).to_yaml
      f.rewind
      cfg = Aws::SessionStore::DynamoDB::Configuration.new(options.merge(config_file: f.path))
      expect(cfg.to_hash).to include(options)
    ensure
      teardown_env(options.merge(old))
    end
  end

  it 'allows for config file to be configured with ENV' do
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      f << options.transform_keys(&:to_s).to_yaml
      f.rewind
      ENV['DYNAMO_DB_SESSION_CONFIG_FILE'] = f.path
      cfg = Aws::SessionStore::DynamoDB::Configuration.new
      expect(cfg.to_hash).to include(options)
    ensure
      ENV.delete('DYNAMO_DB_SESSION_CONFIG_FILE')
    end
  end

  it 'ignores certain keys in ENV' do
    ENV['DYNAMO_DB_SESSION_DYNAMO_DB_CLIENT'] = 'Client'
    ENV['DYNAMO_DB_SESSION_ERROR_HANDLER'] = 'Handler'
    cfg = Aws::SessionStore::DynamoDB::Configuration.new
    expect(cfg.to_hash).to include(defaults)
  ensure
    ENV.delete('DYNAMO_DB_SESSION_DYNAMO_DB_CLIENT')
    ENV.delete('DYNAMO_DB_SESSION_ERROR_HANDLER')
  end

  it 'ignores certain keys in YAML' do
    Tempfile.create('dynamo_db_session_store.yml') do |f|
      options = { dynamo_db_client: 'Client', error_handler: 'Handler', config_file: 'File' }
      f << options.transform_keys(&:to_s).to_yaml
      f.rewind
      cfg = Aws::SessionStore::DynamoDB::Configuration.new(config_file: f.path)
      expect(cfg.to_hash).to include(defaults.merge(config_file: f.path))
    end
  end

  it 'raises an exception when wrong path for file' do
    config_path = 'Wrong path!'
    runtime_opts = { config_file: config_path }.merge(options)
    expect { Aws::SessionStore::DynamoDB::Configuration.new(runtime_opts) }
      .to raise_error(Errno::ENOENT)
  end
end
