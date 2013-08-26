class <%= name.camelize %> < ActiveRecord::Migration
  def up
    AWS::SessionStore::DynamoDB::Table.create_table
  end

  def down
    AWS::SessionStore::DynamoDB::Table.delete_table
  end
end

