# frozen_string_literal: true

namespace 'dynamo_db' do
  namespace 'session_store' do
    desc 'Create the Amazon DynamoDB session store table'
    task create: :environment do
      Aws::SessionStore::DynamoDB::Table.create_table
    end

    desc 'Delete the Amazon DynamoDB session store table'
    task delete: :environment do
      Aws::SessionStore::DynamoDB::Table.delete_table
    end

    desc 'Clean up old sessions in the Amazon DynamoDB session store table'
    task clean: :environment do
      Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage
    end
  end
end
