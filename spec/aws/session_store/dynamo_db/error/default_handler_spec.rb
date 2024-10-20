# frozen_string_literal: true

require 'spec_helper'

describe Aws::SessionStore::DynamoDB do
  include Rack::Test::Methods

  let(:missing_key_error) { Aws::SessionStore::DynamoDB::Errors::MissingSecretKeyError }
  let(:resource_error_msg) { 'The Resource is not found' }
  let(:resource_error) do
    Aws::DynamoDB::Errors::ResourceNotFoundException.new(double('Seahorse::Client::RequestContext'), resource_error_msg)
  end
  let(:key_error_msg) { 'The provided key element does not match the schema' }
  let(:key_error) do
    Aws::DynamoDB::Errors::ValidationException.new(double('Seahorse::Client::RequestContext'), key_error_msg)
  end
  let(:client_error_msg) { 'Unrecognized Client' }
  let(:client_error) do
    Aws::DynamoDB::Errors::UnrecognizedClientException.new(double('Seahorse::Client::RequestContext'), client_error_msg)
  end

  let(:options) do
    { dynamo_db_client: client, secret_key: 'meltingbutter' }
  end

  let(:base_app) { MultiplierApplication.new }
  let(:app) { Aws::SessionStore::DynamoDB::RackMiddleware.new(base_app, options) }
  let(:client) { Aws::DynamoDB::Client.new(stub_responses: true) }

  it 'raises error for missing secret key' do
    allow(client).to receive(:update_item).and_raise(missing_key_error)
    expect { get '/' }.to raise_error(missing_key_error)
  end

  it 'catches exception for inaccurate table name and raises error ' do
    allow(client).to receive(:update_item).and_raise(resource_error)
    expect { get '/' }.to raise_error(resource_error)
  end

  it 'catches exception for inaccurate table key' do
    allow(client).to receive(:update_item).and_raise(key_error)
    allow(client).to receive(:get_item).and_raise(key_error)

    get '/'
    expect(last_request.env['rack.errors'].string).to include(key_error_msg)
  end

  context 'raise_error is true' do
    before do
      options[:raise_errors] = true
    end

    it 'raises all errors' do
      allow(client).to receive(:update_item).and_raise(client_error)
      expect { get '/' }.to raise_error(client_error)
    end

    it 'catches exceptions for inaccurate table key and raises error' do
      allow(client).to receive(:update_item).and_raise(key_error)
      expect { get '/' }.to raise_error(key_error)
    end
  end
end
