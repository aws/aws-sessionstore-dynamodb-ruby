module Aws::SessionStore::DynamoDB
  class Railtie < Rails::Railtie
    initializer 'aws-sessionstore-dynamodb-rack-middleware' do
      ActionDispatch::Session::DynamodbStore = Aws::SessionStore::DynamoDB::RackMiddleware
    end
  end
end
