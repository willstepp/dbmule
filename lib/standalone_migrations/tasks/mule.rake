require File.expand_path("../../../standalone_migrations", __FILE__)

namespace :mule do

  task :migrate, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to migrate"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)

    Rake::Task["db:migrate"].invoke
  end

  namespace :migrate do
    task :up, :db do |t, args|
      db = args[:db] || ENV[
      'db']

      unless db
        puts "Error: must provide name of database to migrate"
        puts "For example: rake #{t.name} db=my_cool_database"
        abort
      end

      set_rails_config_for(db)

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

      set_rails_config_for(db)

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

    set_rails_config_for(db)
    
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

    set_rails_config_for(db)

    Rake::Task["db:rollback"].invoke
  end

  task :create, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:create"].invoke
  end

  task :drop, :db do |t, args|
    db = args[:db] || ENV[
      'db']
    
    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:drop"].invoke
  end

  task :reset, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:reset"].invoke
  end

  task :redo, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:redo"].invoke
  end

  namespace :schema do
    task :load, :db do |t, args|
      db = args[:db] || ENV[
      'db']

      unless db
        puts "Error: must provide name of database to rollback"
        puts "For example: rake #{t.name} db=my_cool_database"
        abort
      end

      set_rails_config_for(db)
      Rake::Task["db:schema:load"].invoke
    end

    task :dump, :db do |t, args|
      db = args[:db] || ENV[
      'db']

      unless db
        puts "Error: must provide name of database to rollback"
        puts "For example: rake #{t.name} db=my_cool_database"
        abort
      end

      set_rails_config_for(db)
      Rake::Task["db:schema:dump"].invoke
    end
  end

  task :drop, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:drop"].invoke
  end

  task :setup, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:setup"].invoke
  end

  task :seed, :db do |t, args|
    db = args[:db] || ENV[
      'db']

    unless db
      puts "Error: must provide name of database to rollback"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    set_rails_config_for(db)
    Rake::Task["db:seed"].invoke
  end

  namespace :fixtures do
    task :load, :db do |t, args|
      db = args[:db] || ENV[
      'db']

      unless db
        puts "Error: must provide name of database to rollback"
        puts "For example: rake #{t.name} db=my_cool_database"
        abort
      end

      set_rails_config_for(db)
      Rake::Task["db:fixtures:load"].invoke
    end
  end
end


def set_rails_config_for(database_name)
  paths = Rails.application.config.paths
  paths.add "config/database", :with => File.join(database_name, "db/config.yml")
  paths.add "db/migrate", :with => File.join(database_name, "db/migrate")
  paths.add "db/seeds", :with => File.join(database_name, "db/seeds.rb")
  paths.add "db/schema", :with => File.join(database_name, "db/schema.rb")
  paths.add "db", :with => File.join(database_name, "db")
  ENV['DB_STRUCTURE'] = File.join(database_name, "db/structure.sql")

  #for use in configurator initialize
  ENV["DB_NAME"] = database_name + "/"
end

#https://github.com/rails/rails/blob/master/activerecord/lib/active_record/railties/databases.rake