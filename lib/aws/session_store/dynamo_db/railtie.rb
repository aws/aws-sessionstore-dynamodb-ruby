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


module AWS::SessionStore::DynamoDB
  class Railtie < Rails::Railtie
    initializer 'aws-sessionstore-dynamodb-rack-middleware' do
      ActionDispatch::Session::DynamodbStore = AWS::SessionStore::DynamoDB::RackMiddleware
    end

    # Load all rake tasks
    rake_tasks do
      Dir[File.expand_path("../tasks/*.rake", __FILE__)].each do |rake_task|
        load rake_task
      end
    end
  end
end
