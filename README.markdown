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

    $ rake mule:new_project db=cat_sex_database

Mule will then create a directory in your project's base directory called whatever you put in for `cat_sex_database` above. Inside it will create the basic Mule project structure, which looks like this:

    cat_sex_database/
      db/
        migrate/
        sql/
        seeds/
        config.yml
        seeds.rb

After the project has been created, you will need to edit the `cat_sex_database\db\config.yml` file and enter the correct database connection information for each environment section you require (development, test, production below). You can create an arbitary number of environments, with any names you like:

    development:
      adapter: postgresql
      encoding: unicode
      database: cat_sex_database_development
      pool: 5
      username:
      password:
      host: localhost

    test:
      adapter: postgresql
      encoding: unicode
      database: cat_sex_database_test
      pool: 5
      username:
      password:
      host: localhost

    production:
      adapter: postgresql
      encoding: unicode
      database: cat_sex_database_production
      pool: 5
      username: ENV['CAT_SEX_DATABASE_USER']
      password: ENV['CAT_SEX_DATABASE_PSWD']
      host: ENV['CAT_SEX_DATABASE_HOST']

####Enable migrations on an existing database

Sometimes you will need to create a database project for an existing database. To do so, follow the instructions above and then run the following command: 

    $ rake mule:configure_existing_database db=cat_sex_database

This will add an initial database version to your database with the contents of a schema dump, so that it can be recreated in other environments.

#### Create a migration:

    rake mule:new_migration db=cat_sex_database name=new_cat_sex_migration

#### Migrate database to latest version:

    rake mule:migrate db=cat_sex_database

#### Migrate database to specific version (up or down depending on current version):

    rake mule:migrate db=cat_sex_database VERSION=<specific_version_number>

#### Run a specific migration:

    rake mule:migrate:up db=cat_sex_database VERSION=<specific_version_number>

or

    rake mule:migrate:down db=cat_sex_database VERSION=<specific_version_number>

#### Rollback database to previous version:

    rake mule:rollback db=cat_sex_database

#### Rollback database a certain number of steps:

    rake mule:rollback db=cat_sex_database STEP=<how_many_rollbacks>

#### Seed database:

    rake mule:seed db=cat_sex_database

#### Retrieve database version:

    rake mule:version db=cat_sex_database

#### Create database:

    rake mule:create db=cat_sex_database

#### Drop database:

    rake mule:drop db=cat_sex_database

#### Reset database:

    rake mule:reset db=cat_sex_database

#### Dump schema:

    rake mule:structure:dump db=cat_sex_database

#### Load schema:

    rake mule:structure:load db=cat_sex_database

### Notes for production:

Mule has a safeguard system in place for any `config.yml` environment that contains the word 'production'. If you run any command that is typically destructive in nature (i.e. data could be lost), then it is required that you pass in an additional confirmation flag to the command...

How to pass in environment variables...