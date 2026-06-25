# frozen_string_literal: true

require 'spec_helper'

module Aws
  module SessionStore
    module DynamoDB
      module Locking
        describe Base do
          let(:dynamo_db_client) do
            Aws::DynamoDB::Client.new(stub_responses: true)
          end

          let(:options) do
            {
              dynamo_db_client: dynamo_db_client,
              secret_key: 'test_key'
            }
          end

          let(:config) { Configuration.new(options) }
          let(:handler) { Base.new(config) }
          let(:session_data) { { 'user_id' => 123, 'name' => 'test' } }

          describe '#pack_data / #unpack_data' do
            context 'with serializer: :json (default via :json_allow_marshal)' do
              it 'packs data as JSON' do
                packed = handler.send(:pack_data, session_data)
                expect(packed).to eq('{"user_id":123,"name":"test"}')
              end

              it 'unpacks JSON data' do
                packed = JSON.dump(session_data)
                unpacked = handler.send(:unpack_data, packed)
                expect(unpacked).to eq(session_data)
              end
            end

            context 'with serializer: :json_allow_marshal' do
              it 'unpacks legacy Base64-encoded Marshal data' do
                legacy_packed = [Marshal.dump(session_data)].pack('m*')
                unpacked = handler.send(:unpack_data, legacy_packed)
                expect(unpacked).to eq(session_data)
              end

              it 'prefers JSON when data is valid JSON' do
                json_packed = JSON.dump(session_data)
                unpacked = handler.send(:unpack_data, json_packed)
                expect(unpacked).to eq(session_data)
              end

              it 'packs new data as JSON, not Marshal' do
                packed = handler.send(:pack_data, session_data)
                expect { JSON.parse(packed) }.not_to raise_error
              end
            end

            context 'with serializer: :json' do
              let(:options) do
                {
                  dynamo_db_client: dynamo_db_client,
                  secret_key: 'test_key',
                  serializer: :json
                }
              end

              it 'packs data as JSON' do
                packed = handler.send(:pack_data, session_data)
                expect(packed).to eq('{"user_id":123,"name":"test"}')
              end

              it 'unpacks JSON data' do
                packed = JSON.dump(session_data)
                unpacked = handler.send(:unpack_data, packed)
                expect(unpacked).to eq(session_data)
              end

              it 'raises on legacy Marshal data' do
                legacy_packed = [Marshal.dump(session_data)].pack('m*')
                expect { handler.send(:unpack_data, legacy_packed) }.to raise_error(JSON::ParserError)
              end
            end

            context 'with serializer: :marshal' do
              let(:options) do
                {
                  dynamo_db_client: dynamo_db_client,
                  secret_key: 'test_key',
                  serializer: :marshal
                }
              end

              it 'packs data as Base64-encoded Marshal' do
                packed = handler.send(:pack_data, session_data)
                unpacked = Marshal.load(packed.unpack1('m*')) # rubocop:disable Security/MarshalLoad
                expect(unpacked).to eq(session_data)
              end

              it 'unpacks Base64-encoded Marshal data' do
                packed = [Marshal.dump(session_data)].pack('m*')
                unpacked = handler.send(:unpack_data, packed)
                expect(unpacked).to eq(session_data)
              end
            end
          end
        end
      end
    end
  end
end
