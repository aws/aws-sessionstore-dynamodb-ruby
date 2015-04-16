class <%= name.camelize %> < ActiveRecord::Migration
  def up
    Aws::SessionStore::DynamoDB::Table.create_table
  end

  def down
    Aws::SessionStore::DynamoDB::Table.delete_table
  end
end

