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

    rake mule:new_project db=foo_bar_database

Mule will then create a directory in your project's base directory called whatever you put in for `foo_bar_database` above. Inside it will create the basic Mule project structure, which looks like this:

    foo_bar_database/
      db/
        migrate/
        sql/
        seeds/
        config.yml
        seeds.rb

After the project has been created, you will need to edit the `foo_bar_database\db\config.yml` file and enter the correct database connection information for each environment section you require (development, test, production below). You can create an arbitary number of environments, with any names you like:

    development:
      adapter: postgresql
      encoding: unicode
      database: foo_bar_database_development
      pool: 5
      username:
      password:
      host: localhost

    test:
      adapter: postgresql
      encoding: unicode
      database: foo_bar_database_test
      pool: 5
      username:
      password:
      host: localhost

    production:
      adapter: postgresql
      encoding: unicode
      database: foo_bar_database_production
      pool: 5
      username: ENV['FOO_BAR_DATABASE_USER']
      password: ENV['FOO_BAR_DATABASE_PSWD']
      host: ENV['FOO_BAR_DATABASE_HOST']

####Changing the current environment

Any command you run will default to the `development` environment, but you can specify which environment you want to run using RAILS_ENV:

    $ rake mule:migrate db=foo_bar_database RAILS_ENV=production

####Enable migrations on an existing database

Sometimes you will need to create a database project for an existing database. To do so, follow the instructions above and then run the following command: 

    $ rake mule:configure_existing_database db=foo_bar_database

This will add an initial database version to your database with the contents of a schema dump, so that it can be recreated in other environments.

####Create a migration:

    $ rake mule:new_migration db=foo_bar_database name=foo_bar_migration

A migration represents a single change you want to make in the database, such as adding a table, adding a column, creating an index, dropping a column, dropping a database, dropping and index, defining a stored procedure...and so on. 

A migration has both an UP and DOWN implementation: UP to make the change and DOWN to undo it. When you call the command above, by default Mule will create two SQL scripts in the `foo_bar_database/db/sql` directory. The format of the filenames are:

    <timestamp>_<name_of_migration>_up.sql
    <timestamp>_<name_of_migration>_down.sql

    example: 20130128185251_foo_bar_migration_up.sql
    example: 20130128185251_foo_bar_migration_down.sql

These files are plain old SQL files and that's all they should contain.

Using Ruby

If you want to use the ActiveRecord domain-specific language to write your migrations instead of SQL, pass into the command the flag `type=ruby' so that the SQL scripts are not generated and then edit both the up and down methods of the file created in the `foo_bar_database/db/migrate' directory. The format of the filename is:

    <timestamp>_<name_of_migration>.rb

    example: 20130128185251_foo_bar_migration.rb

####Migrate database to latest version:

    $ rake mule:migrate db=foo_bar_database

This command will run any migrations that have not been run on the database.

####Migrate database to specific version (up or down depending on current version):

    $ rake mule:migrate db=foo_bar_database VERSION=<specific_version_number>

####Run a single, specific migration:

    $ rake mule:migrate:up db=foo_bar_database VERSION=<specific_version_number>

    or

    $ rake mule:migrate:down db=foo_bar_database VERSION=<specific_version_number>

####Rollback database to the previous version:

    $ rake mule:rollback db=foo_bar_database

####Rollback database a certain number of steps:

    $ rake mule:rollback db=foo_bar_database STEP=<how_many_steps>

####Seed database:

    $ rake mule:seed db=foo_bar_database

####Retrieve database version:

    $ rake mule:version db=foo_bar_database

####Create database:

    $ rake mule:create db=foo_bar_database

####Drop database:

    $ rake mule:drop db=foo_bar_database

####Reset database:

    $ rake mule:reset db=foo_bar_database

####Dump schema:

    $ rake mule:structure:dump db=foo_bar_database

####Load schema:

    $ rake mule:structure:load db=foo_bar_database

###Notes for production:

####Database environment variables

The `foo_bar_database/db/config.yml` file can contain environment variable accessors, in the format: ENV['FOO_BAR_VARIABLE']. 

    production:
      adapter: postgresql
      encoding: unicode
      database: foo_bar_database_production
      pool: 5
      username: ENV['FOO_BAR_USER']
      password: ENV['FOO_BAR_PSWD']
      host: ENV['FOO_BAR_HOST']

You can use this for production configurations to pass in database configuration during execution of the command:

    $ rake mule:migrate db=foo_bar_database RAILS_ENV=production FOO_BAR_USER=<prod_user> FOO_BAR_PSWD=<prod_pswd> FOO_BAR_HOST=<prod_host>

####Safeguard for destructive commands

Mule has a safeguard system in place for any `foo_bar_database/db/config.yml` environment that contains the word 'production'. If you run any command that is typically destructive in nature (i.e. data could be lost), then it is required that you pass in an additional confirm argument to the command. The confirm argument must contain the database project name: 

    $ rake mule:rollback confirm=foo_bar_database db=foo_bar_database RAILS_ENV=production