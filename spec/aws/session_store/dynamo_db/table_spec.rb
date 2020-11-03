require 'spec_helper'
require 'stringio'
require 'logger'

module Aws
  module SessionStore
    module DynamoDB
      describe Table do
        context "Mock Table Methods Tests", :integration => true do
          let(:table_name) { "sessionstore-integration-test-#{Time.now.to_i}" }
          let(:options) { {:table_name => table_name} }
          let(:io) { StringIO.new }

          before { Table.stub(:logger) { Logger.new(io) } }

          it "Creates and deletes a new table" do
            Table.create_table(options)

            # second attempt should warn
            Table.create_table(options)

            io.string.should include("Table #{table_name} created, waiting for activation...\n")
            io.string.should include("Table #{table_name} is now ready to use.\n")
            io.string.should include("Table #{table_name} already exists, skipping creation.\n")

            # now delete table
            Table.delete_table(options)
          end
        end
      end
    end
  end
end
