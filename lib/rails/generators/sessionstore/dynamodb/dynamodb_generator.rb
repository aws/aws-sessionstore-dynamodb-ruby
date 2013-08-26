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

require 'rails/generators/named_base'

# This class generates
# a migration file for deleting and creating
# a DynamoDB sessions table.
module Sessionstore
  module Generators
    class DynamodbGenerator < Rails::Generators::NamedBase
      include Rails::Generators::Migration

      source_root File.expand_path('templates', File.dirname(__FILE__))

      # Desired name of migration class
      argument :name, :type => :string, :default => "sessionstore_migration"

      # @return [Rails Migration File] migration file for creation and deletion of
      #   session table.
      def generate_migration_file
        migration_template "sessionstore_migration.rb",
          "#{Rails.root}/db/migrate/#{file_name}"
      end


      def copy_sample_config_file
        file = File.join("sessionstore", "dynamodb.yml")
        template file, File.join(Rails.root, "config", file)
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
  end
end
