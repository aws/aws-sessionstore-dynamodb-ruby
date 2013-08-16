class <%= name.camelize %> < ActiveRecord::Migration
  def up
    AWS::DynamoDB::SessionStore::Table.create_table
  end

  def down
    AWS::DynamoDB::SessionStore::Table.delete_table
  end
end

