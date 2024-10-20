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

For more developer information, see the [Full API documentation][1].

## Installation

Add this gem to your Rack application's Gemfile:

```ruby
gem 'aws-sessionstore-dynamodb', '~> 3'
```

## Creating the session table

After installation, you must create the session table. In a Rails application,
you can either use the provided ActiveRecord generator or use the provided
Rake task. In a Rack application, you can use the provided Ruby methods.

### Rails ActiveRecord generator

You can generate a migration file for the session table using the following
command (<MigrationName> is optional):

```bash
rails generate dynamo_db:session_store_migration <MigrationName>
```

The session store migration generator command will generate two	files: a
migration file, `db/migration/#{VERSION}_#{MIGRATION_NAME}.rb`, and a
configuration YAML file, `config/dynamo_db_session_store.yml`.

The migration file will create and delete a table with default options. These
options can be changed prior to running the migration either in code or in the
config YAML file and are documented in the [Table][2] class.

To create the table, run migrations as normal with:

```bash
rails db:migrate
```

To delete the table and rollback, run the following command:

```bash
rails db:migrate:down VERSION=<VERSION>
```

### Rails Rake task

If you are using Rails but do not use ActiveRecord, you can create the table
using the provided Rake tasks:

```bash
rake dynamo_db:session_store:create
rake dynamo_db:session_store:delete
```

The rake tasks will create and delete a table with default options. These
options can be changed prior to running the task in the config YAML file and are
documented in the [Table][2] class.

### Rack application

If you are not using Rails or if you want explicit control in creating and
deleting the table, you can use the following Ruby methods:

```ruby
options = {}
Aws::SessionStore::DynamoDB::Table.create_table(options)
Aws::SessionStore::DynamoDB::Table.delete_table(options)
```

## Usage

### Rails application

To use the session store in a Rails application, add the following to your
`config/initializers/session_store.rb` file:

```ruby
options = { table_name: '_your_app_session' }
Rails.application.config.session_store :dynamo_db_store, **options
```

You can now start your Rails application with session support.

### Rack application

Run the session store as a Rack middleware in the following way:

    require 'aws-sessionstore-dynamodb'
    require 'some_rack_app'

    options = { :secret_key => 'SECRET_KEY' }

    use Aws::SessionStore::DynamoDB::RackMiddleware.new(options)
    run SomeRackApp

Note that `:secret_key` is a mandatory configuration option that must be set.

### Configuration Options

A number of options are available to be set in
`Aws::SessionStore::DynamoDB::Configuration`, which is used by the
`RackMiddleware` class. These options can be set directly by Ruby code, through
a YAML configuration file, or Environment variables, in order of precedence.

The full set of options along with defaults can be found in the
[Configuration][3] documentation.

#### YAML Configuration

You can create a YAML configuration file to set the options. If using a Rack
application or overriding options in migrations, the file must be passed into
configuration as the `:config_file` option.

If you are using Rails, the config file will be searched automatically if placed
in either of these directories:

```ruby
config/dynamo_db_session_store/#{Rails.env}.yml
config/dynamo_db_session_store.yml
```

#### Environment Options

Certain configuration options can be loaded from the environment. These
options must be specified in the following format:

    DYNAMO_DB_SESSION_<name-of-option>

The example below would be a valid way to set the session table name:

    export DYNAMO_DB_SESSION_TABLE_NAME='sessions'

### Garbage Collection

You may want to delete old sessions from your session table. You can use the
DynamoDB [Time to Live (TTL) feature][4] on the `expire_at` attribute to
automatically delete expired items.

If you are using Rails, a Rake task is provided to perform garbage collection:

```bash
rake dynamo_db:session_store:clean
```

The garbage collection will use the default options or config options from
environment variables or a YAML file. The default options are to delete all
sessions. `:max_age` and `:max_stale` options should be set to delete sessions
older than a certain age or that have been stale for a certain amount of time.

If you are not using Rails or if you want explicit control over garbage
collection, you can create your own Rake task:

```ruby
desc 'Perform Garbage Collection'
task :garbage_collect do
  options = {:max_age => 3600*24, max_stale => 5*3600 }
  Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage(options)
end
```

The above example will clear sessions older than one day or that have been
stale for longer than an hour.

### Error Handling

You can pass in your own error handler for raised exceptions or you can allow
the default error handler to them for you. See the API documentation
on the {Aws::SessionStore::DynamoDB::Errors::BaseHandler} class for more
details.

[1]: https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/

[2]: https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Table.html

[3]: https://docs.aws.amazon.com/sdk-for-ruby/aws-sessionstore-dynamodb/api/Aws/SessionStore/DynamoDB/Configuration.html

[4]: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html
