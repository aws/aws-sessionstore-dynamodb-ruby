# Amazon DynamoDB Session Store

This gem handles sessions for Ruby web applications using a DynamoDB backend.
It is compatible with all Rack based frameworks including Rails.

A DynamoDB backend provides scaling and centralized data benefits for session
storage with more ease than other containers, like local servers or cookies.
Once an application scales beyond a single web server, session data will need to
be shared across the servers. Cookie storage places all session data on the
client side, discouraging sensitive data storage. It also forces strict data size
limitations. DynamoDB takes care of these concerns by allowing for a safe and
scalable storage container with a much larger data size limit for session data.

For more developer information, see the
[Full API documentation](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/).

## Installation

Add this gem to your Rack application's Gemfile:

```ruby
gem 'aws-sessionstore-dynamodb', '~> 3'
```

If you are using Rails, please include the
[aws-sdk-rails](https://github.com/aws/aws-sdk-rails)
gem for
[extra functionality](https://github.com/aws/aws-sdk-rails?tab=readme-ov-file#dynamodb-session-store),
including generators for the session table, ActionDispatch Session integration,
a garbage collection Rake task, and more:

```ruby
gem 'aws-sdk-rails', '~> 4'
```

## Configuration

A number of options are available to be set in
`Aws::SessionStore::DynamoDB::Configuration`, which is used throughout the
application. These options can be set directly in Ruby code, in ENV variables,
or in a YAML configuration file, in order of precedence.

The full set of options along with defaults can be found in the
[Configuration](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html)
documentation.

### Environment Options

All Configuration options can be loaded from the environment except for
`:dynamo_db_client` and `:error_handler`, which must be set in Ruby code
directly if needed. The environment options must be prefixed with
`DYNAMO_DB_SESSION_` and then the name of the option:

    DYNAMO_DB_SESSION_<name-of-option>

The example below would be a valid way to set the session table name:

    export DYNAMO_DB_SESSION_TABLE_NAME='your-table-name'

### YAML Configuration

You can create a YAML configuration file to set the options. The file must be
passed into Configuration as the `:config_file` option or with the
`DYNAMO_DB_SESSION_CONFIG_FILE` environment variable.

## Creating the session table

After installation and configuration, you must create the session table using
the following Ruby methods:

```ruby
options = { table_name: 'your-table-name' } # overrides from YAML or ENV
Aws::SessionStore::DynamoDB::Table.create_table(options)
Aws::SessionStore::DynamoDB::Table.delete_table(options)
```

## Usage

Run the session store as a Rack middleware in the following way:

```ruby
require 'aws-sessionstore-dynamodb'
require 'some_rack_app'

options = { :secret_key => 'secret' } # overrides from YAML or ENV

use Aws::SessionStore::DynamoDB::RackMiddleware.new(options)
run SomeRackApp
```

Note that `:secret_key` is a mandatory configuration option that must be set.

`RackMiddleware` inherits from the `Rack::Session::Abstract::Persisted` class,
which also includes additional options (such as `:key`) that can be set.

The `RackMiddleware` inherits from the
[Rack::Session::Abstract::Persisted](https://rubydoc.info/github/rack/rack-session/main/Rack/Session/Abstract/Persisted)
class, which also includes additional options (such as `:key`) that can be
passed into the class.

### Garbage Collection

By default sessions do not expire. You can use `:max_age` and `:max_stale` to
configure the max age or stale period of a session.

You can use the DynamoDB
[Time to Live (TTL) feature](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html)
on the `expire_at` attribute to automatically delete expired items, saving you
the trouble of manually deleting them and reducing costs.

If you wish to delete old sessions based on creation age (invalidating valid
sessions) or if you want control over the garbage collection process, you can
create your own Rake task:

```ruby
desc 'Perform Garbage Collection'
task :clean_session_table do
  options = { max_age: 3600*24, max_stale: 5*3600 } # overrides from YAML or ENV
  Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage(options)
end
```

The above example will clear sessions older than one day or that have been
stale for longer than an hour.

### Error Handling

You can pass in your own error handler for raised exceptions or you can allow
the default error handler to them for you. See the
[BaseHandler](https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Errors/BaseHandler.html)
documentation for more details on how to create your own error handler.
