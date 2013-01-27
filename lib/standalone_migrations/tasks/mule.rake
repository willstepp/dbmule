require File.expand_path("../../../standalone_migrations", __FILE__)

namespace :db do
  task :migrate, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to migrate"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    paths = Rails.application.config.paths
    paths.add "config/database", :with => File.join(db, "db/config.yml")
    paths.add "db/migrate", :with => File.join(db, "db/migrate")
    paths.add "db/seeds", :with => File.join(db, "db/seeds.rb")
    paths.add "db/schema", :with => File.join(db, "db/schema.rb")
    paths.add "db", :with => File.join(db, "db")
    ENV['DB_STRUCTURE'] = File.join(db, "db/structure.sql")

    #for use in configurator initialize
    ENV["DB_NAME"] = db + "/"

    Rake::Task["db:migrate"].invoke

    task :up, :db do |t, args|
      db = args[:db] || ENV[
      'db']

      unless db
        puts "Error: must provide name of database to migrate"
        puts "For example: rake #{t.name} db=my_cool_database"
        abort
      end

      paths = Rails.application.config.paths
      paths.add "config/database", :with => File.join(db, "db/config.yml")
      paths.add "db/migrate", :with => File.join(db, "db/migrate")
      paths.add "db/seeds", :with => File.join(db, "db/seeds.rb")
      paths.add "db/schema", :with => File.join(db, "db/schema.rb")
      paths.add "db", :with => File.join(db, "db")
      ENV['DB_STRUCTURE'] = File.join(db, "db/structure.sql")

      Rake::Task["db:migrate:up"].invoke
    end

    task :down, :db do |t, args|
      db = args[:db] || ENV[
      'db']

      unless db
        puts "Error: must provide name of database to migrate"
        puts "For example: rake #{t.name} db=my_cool_database"
        abort
      end

      paths = Rails.application.config.paths
      paths.add "config/database", :with => File.join(db, "db/config.yml")
      paths.add "db/migrate", :with => File.join(db, "db/migrate")
      paths.add "db/seeds", :with => File.join(db, "db/seeds.rb")
      paths.add "db/schema", :with => File.join(db, "db/schema.rb")
      paths.add "db", :with => File.join(db, "db")
      ENV['DB_STRUCTURE'] = File.join(db, "db/structure.sql")

      Rake::Task["db:migrate:down"].invoke
    end
  end

  task :new_migration, :name, :db, :options do |t, args|
    name = args[:name] || ENV['name']
    db = args[:db] || ENV[
      'db']
    options = args[:options] || ENV['options']

    unless db
      puts "Error: must provide name of database to generate migration for."
      puts "For example: rake #{t.name} db=my_cool_database name=add_field_to_form"
      abort
    end
    
    unless name
      puts "Error: must provide name of migration to generate."
      puts "For example: rake #{t.name} name=add_field_to_form"
      abort
    end
    
    if options
      StandaloneMigrations::Generator.migration name, db, options.gsub('/', ' ')
    else
      StandaloneMigrations::Generator.migration name, db
    end
  end

  task :rollback, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    paths = Rails.application.config.paths
    paths.add "config/database", :with => File.join(db, "db/config.yml")
    paths.add "db/migrate", :with => File.join(db, "db/migrate")
    paths.add "db/seeds", :with => File.join(db, "db/seeds.rb")
    paths.add "db/schema", :with => File.join(db, "db/schema.rb")
    paths.add "db", :with => File.join(db, "db")
    ENV['DB_STRUCTURE'] = File.join(db, "db/structure.sql")

    #for use in configurator initialize
    ENV["DB_NAME"] = db + "/"

    Rake::Task["db:rollback"].invoke
  end
end

#https://github.com/rails/rails/blob/master/activerecord/lib/active_record/railties/databases.rake