# Amazon DynamoDB Session Store

The **Amazon DynamoDB Session Store** handles sessions for Ruby web applications
using a DynamoDB backend. The session store is compatible with Rails (3.x or 4.x)
and other Rack based frameworks.

## Installation

#### Rails Installation

Install the session store gem by placing the following command into your
Gemfile:

    gem 'aws-sessionstore-dynamodb'

You will need to have an existing Amazon DynamoDB session table in order for the
application to work. You can generate a migration file for the session table
with the following command:

    rails generate sessionstore:dynamodb

To create the table, run migrations as normal with:

    rake db:migrate

Change the session store to `:dynamodb_store` by editing
`config/initializers/session_store.rb` to contain the following:

    YourAppName::Application.config.session_store :dynamodb_store

You can now start your Rails application with session support.

#### Basic Rack Application Installation

For non-Rails applications, you can create the Amazon DynamoDB table in a
Ruby file using the following method:

    require 'aws-sessionstore-dynamodb'

    Aws::SessionStore::DynamoDB::Table.create_table

Run the session store as a Rack middleware in the following way:

    require 'aws-sessionstore-dynamodb'
    require 'some_rack_app'

    options = { :secret_key => 'SECRET_KEY' }

    use Aws::SessionStore::DynamoDB::RackMiddleware.new(options)
    run SomeRackApp

Note that `:secret_key` is a mandatory configuration option that must be set.

## Detailed Usage

The session store is a Rack Middleware, meaning that it will implement the Rack
interface for dealing with HTTP request/responses.

This session store uses a DynamoDB backend in order to provide scaling and
centralized data benefits for session storage with more ease than other
containers, like local servers or cookies. Once an application scales beyond
a single web server, session data will need to be shared across the servers.
DynamoDB takes care of this burden for you by scaling with your application.
Cookie storage places all session data on the client side,
discouraging sensitive data storage. It also forces strict data size
limitations. DynamoDB takes care of these concerns by allowing for a safe and
scalable storage container with a much larger data size limit for session data.

Full API documentation of the library can be found on [RubyDoc.info][1].

### Configuration Options

A number of options are available to be set in
`Aws::SessionStore::DynamoDB::Configuration`, which is used by the
`RackMiddleware` class. These options can be set in the YAML configuration
file in a Rails application (located in `config/sessionstore/dynamodb.yml`),
directly by Ruby code, or through environment variables.

The full set of options along with defaults can be found in the
[Configuration class documentation][2].

#### Environment Options

Certain configuration options can be loaded from the environment. These
options must be specified in the following format:

    DYNAMO_DB_SESSION_NAME-OF-CONFIGURATION-OPTION

The example below would be a valid way to set the session table name:

    export DYNAMO_DB_SESSION_TABLE_NAME='sessions'

### Rails Generator Details

The generator command specified in the installation section will generate two
files: a migration file, `db/migration/VERSION_migration_name.rb`, and a
configuration YAML file, `config/sessionstore/dynamodb.yml`.

You can run the command with an argument that will define the name of the
migration file. Once the YAML file is created, you can uncomment any of the
lines to set configuration options to your liking. The session store will pull
options from `config/sessionstore/dynamodb.yml` by default if the file exists.
If you do not wish to place the configuration YAML file in that location,
you can also pass in a different file path to pull options from.

### Garbage Collection

You may want to delete old sessions from your session table. The
following examples show how to clear old sessions from your table.

#### Rails

A Rake task for garbage collection is provided for Rails applications.
By default sessions do not expire. See `config/sessionstore/dynamodb.yml` to
configure the max age or stale period of a session. Once you have configured
those values you can clear the old sessions with:

    rake dynamo_db:collect_garbage

#### Outside of Rails

You can create your own Rake task for garbage collection similar to below:

    require "aws-sessionstore-dynamodb"

    desc 'Perform Garbage Collection'
    task :garbage_collect do |t|
     options = {:max_age => 3600*24, max_stale => 5*3600 }
     Aws::SessionStore::DynamoDB::GarbageCollection.collect_garbage(options)
    end

The above example will clear sessions older than one day or that have been
stale for longer than an hour.

### Locking Strategy

You may want the Session Store to implement the provided pessimistic locking
strategy if you are concerned about concurrency issues with session accesses.
By default, locking is not implemented for the session store. You must trigger
the locking strategy through the configuration of the session store. Pessimistic
locking, in this case, means that only one read can be made on a session at
once. While the session is being read by the process with the lock, other
processes may try to obtain a lock on the same session but will be blocked.

Locking is expensive and will drive up costs depending on how it is used.
Without locking, one read and one write are performed per request for session
data manipulation. If a locking strategy is implemented, as many as the total
maximum wait time divided by the lock retry delay writes to the database.
Keep these considerations in mind if you plan to enable locking.

#### Configuration for Locking

The following configuration options will allow you to configure the pessimistic
locking strategy according to your needs:

    options = {
      :enable_locking => true,
      :lock_expiry_time => 500,
      :lock_retry_delay => 500,
      :lock_max_wait_time => 1
    }

### Error Handling

You can pass in your own error handler for raised exceptions or you can allow
the default error handler to them for you. See the API documentation
on the {Aws::SessionStore::DynamoDB::Errors::BaseHandler} class for more
details.

[1]: http://rubydoc.org/gems/aws-sessionstore-dynamodb/frames
[2]: http://rubydoc.org/gems/aws-sessionstore-dynamodb/Aws/SessionStore/DynamoDB/Configuration#initialize-instance_method
