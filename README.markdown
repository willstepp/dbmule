## Mule

###What is it?

Mule is a database migration tool based on a stand-alone version of [Rails Migrations](http://guides.rubyonrails.org/migrations.html). By default, Mule uses SQL scripts instead of Migrations DSL, so no Ruby coding is required. It supports multi-database environments, including support for existing databases.

You interact with Mule via a series of [Rake](http://rake.rubyforge.org/) commands which map almost 1:1 to Rails Migrations commands, so if you are familiar with them you will be right at home, but if not, don't worry -- it's really easy.

These commands give you a simple, yet powerful toolset allowing you to manage database migrations across both development and production environments.

###How do I use it?

####Prerequisites

Before using Mule, you must set up a Ruby environment on your machine. Follow the instructions at the links for [Ruby](http://www.ruby-lang.org/en/downloads/) and [RubyGems](https://rubygems.org/pages/download).

Once you have both Ruby and RubyGems installed, you should install the Ruby database driver for whatever database you are using, for example:

Postgres

    $ gem install pg


####Installation

Once your Ruby environment is set up, installing Mule is no big deal:

    $ gem install dbmule

Next, create a `Rakefile` in your project's base directory containing the following lines:

```ruby
require 'mule_migrations'
MuleMigrations::Tasks.load_tasks
```

Installation is complete, you are now ready to begin using Mule.

####Create a database project

To begin, create a new database project. A database project represents one database in your system. You can do this with one command:

    $ rake mule:new_project db=my_test_database

Mule will then create a directory in your project's base directory called whatever you put in for `my_test_database` above. Inside it will create the basic Mule project structure, which looks like this:

    my_test_database/
      db/
        migrate/
        sql/
        seeds/
        config.yml
        seeds.rb

After the project has been created, you will need to edit the `my_test_database\db\config.yml` file and enter the correct database connection information for each environment section you require (development, test, production below). You can create an arbitary number of environments, with any names you like:

    development:
      adapter: postgresql
      encoding: unicode
      database: my_test_database_development
      pool: 5
      username:
      password:
      host: localhost

    test:
      adapter: postgresql
      encoding: unicode
      database: my_test_database_test
      pool: 5
      username:
      password:
      host: localhost

    production:
      adapter: postgresql
      encoding: unicode
      database: my_test_database_production
      pool: 5
      username: ENV['MY_TEST_DATABASE_USER']
      password: ENV['MY_TEST_DATABASE_PSWD']
      host: ENV['MY_TEST_DATABASE_HOST']

####Enable migrations on an existing database

Sometimes you will need to create a database project for an existing database. To do so, follow the instructions above and then run the following command: 

    $ rake mule:configure_existing_database db=my_test_database

This will add an initial database version to your database with the contents of a schema dump, so that it can be recreated in other environments.

### To create a new database migration:

    rake db:new_migration name=foo_bar_migration
    edit db/migrate/20081220234130_foo_bar_migration.rb

#### If you really want to, you can just execute raw SQL:

```ruby
def up
  execute "insert into foo values (123,'something');"
end

def down
  execute "delete from foo where field='something';"
end
```

### To apply your newest migration:

    rake db:migrate

### To migrate to a specific version (for example to rollback)

    rake db:migrate VERSION=20081220234130

### To migrate a specific database (for example your "testing" database)

    rake db:migrate DB=test ... or ...
    rake db:migrate RAILS_ENV=test

### To execute a specific up/down of one single migration

    rake db:migrate:up VERSION=20081220234130

### To revert your last migration

    rake db:rollback

### To revert your last 3 migrations

    rake db:rollback STEP=3

### Custom configuration

By default, Standalone Migrations will assume there exists a "db/"
directory in your project. But if for some reason you need a specific
directory structure to work with, you can use a configuration file
named .standalone_migrations in the root of your project containing
the following:

```yaml
db:
    seeds: db/seeds.rb
    migrate: db/migrate
    schema: db/schema.rb
config:
    database: db/config.yml
```

These are the configurable options available. You can omit any of
the keys and Standalone Migrations will assume the default values. 

#### Changing environment config in runtime

If you are using Heroku or have to create or change your connection
configuration based on runtime aspects (maybe environment variables),
you can use the `StandaloneMigrations::Configurator.environments_config`
method. Check the usage example:

```ruby
require 'tasks/standalone_migrations'

StandaloneMigrations::Configurator.environments_config do |env|

  env.on "production" do

    if (ENV['DATABASE_URL'])
      db = URI.parse(ENV['DATABASE_URL'])
      return {
        :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        :host     => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..-1],
        :encoding => 'utf8'
      }
    end

    nil
  end

end
```

You have to put this anywhere on your `Rakefile`. If you want to
change some configuration, call the #on method on the object
received as argument in your block passed to ::environments_config
method call. The #on method receives the key to the configuration
that you want to change within the block. The block should return
your new configuration hash or nil if you want the configuration
to stay the same.

Your logic to decide the new configuration need to access some data
in your current configuration? Then you should receive the configuration
in your block, like this:

```ruby
require 'tasks/standalone_migrations'

StandaloneMigrations::Configurator.environments_config do |env|

  env.on "my_custom_config" do |current_custom_config|
    p current_custom_config
    # => the values on your current "my_custom_config" environment
    nil
  end

end
```

#### Exporting Generated SQL

If instead of the database-agnostic `schema.rb` file you'd like to
save the database-specific SQL generated by the migrations, simply
add this to your `Rakefile`.

```ruby
require 'tasks/standalone_migrations'
ActiveRecord::Base.schema_format = :sql
```

You should see a `db/structure.sql` file the next time you run a
migration.
