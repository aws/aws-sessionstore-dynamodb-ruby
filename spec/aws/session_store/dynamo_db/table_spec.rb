# frozen_string_literal: true

require 'spec_helper'

module Aws::SessionStore::DynamoDB
  describe Table, integration: true do
    let(:table_name) { "sessionstore-integration-test-#{Time.now.to_i}" }
    let(:options) { { table_name: table_name } }
    let(:logger) { Logger.new(IO::NULL) }

    before { allow(Table).to receive(:logger).and_return(logger) }

    it 'Creates and deletes a new table' do
      expect(logger).to receive(:info)
        .with("Table #{table_name} created, waiting for activation...")
      expect(logger).to receive(:info)
        .with("Table #{table_name} is now ready to use.")
      Table.create_table(options)

      # second attempt should warn
      expect(logger).to receive(:warn)
        .with("Table #{table_name} already exists, skipping creation.")
      Table.create_table(options)

      expect(logger).to receive(:info)
        .with("Table #{table_name} deleted.")
      Table.delete_table(options)
    end
  end
end
