# Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

# This class generates
# a migration file for deleting and creating
# a DynamoDB sessions table.
class DynamoDbSessionHandler < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  # Desired name of migration class
  argument :name, :type => :string, :default => "dynamo_db_session_migration"

  # @return [Rails Migration File] migration file for creation and deletion of Session table.
  def generate_migration_file
    migration_template "dynamo_db_session.rb", "#{Rails.root}/db/migrate/#{file_name}"
  end


  def copy_sample_config_file
    template "dynamo_db_session.yml", "#{File.join(Rails.root, "config", "dynamo_db_session.yml")}"
  end

  private

  # @return [String] filename
  def file_name
    name.underscore
  end

  # @return [String] migration version using time stamp YYYYMMDDHHSS
  def self.next_migration_number(dir = nil)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
end
