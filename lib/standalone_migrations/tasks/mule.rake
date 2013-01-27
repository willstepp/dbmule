require File.expand_path("../../../standalone_migrations", __FILE__)

namespace :mule do

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

  task :migrate, :db do |t, args|
    invoke_task_for(args[:db] || ENV['db'], t, "db:migrate")
  end

  namespace :migrate do
    task :up, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:migrate:up")
    end

    task :down, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:migrate:down")
    end

    task :redo, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:migrate:redo")
    end

    task :reset, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:migrate:reset")
    end

    task :status, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:migrate:status")
    end

  end

  task :rollback, :db do |t, args|
    invoke_task_for(args[:db] || ENV['db'], t, "db:rollback")
  end

  task :create, :db do |t, args|
    invoke_task_for(args[:db] || ENV['db'], t, "db:create")
  end

  task :drop, :db do |t, args|
    invoke_task_for(args[:db] || ENV['db'], t, "db:drop")
  end

  task :reset, :db do |t, args|
    invoke_task_for(args[:db] || ENV['db'], t, "db:reset")
  end

  task :redo, :db do |t, args|
    invoke_task_for(args[:db] || ENV['db'], t, "db:redo")
  end

  namespace :schema do
    task :dump, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:schema:dump")
    end

    task :load, :db do |t, args|
      invoke_task_for(args[:db] || ENV['db'], t, "db:schema:load")
    end
  end

  namespace :structure do
    task :dump, :db do |t, args|
      invoke_task_for(db = args[:db] || ENV['db'], t, "db:structure:dump")
    end

    task :load, :db do |t, args|
      invoke_task_for(db = args[:db] || ENV['db'], t, "db:structure:load")
    end
  end

  task :drop, :db do |t, args|
    invoke_task_for(db = args[:db] || ENV['db'], t, "db:drop")
  end

  task :setup, :db do |t, args|
    invoke_task_for(db = args[:db] || ENV['db'], t, "db:setup")
  end

  task :seed, :db do |t, args|
    invoke_task_for(db = args[:db] || ENV['db'], t, "db:seed")
  end

  namespace :fixtures do
    task :load, :db do |t, args|
      invoke_task_for(db = args[:db] || ENV['db'], t, "db:fixtures:load")
    end

    task :identify, :db do |t, args|
      invoke_task_for(db = args[:db] || ENV['db'], t, "db:fixtures:identify")
    end
  end

  task :version, :db do |t, args|
    invoke_task_for(db = args[:db] || ENV['db'], t, "db:version")
  end
end

def invoke_task_for(db, current_task, task_to_invoke)
  unless db
    puts "Error: must provide name of database"
    puts "For example: rake #{current_task.name} db=my_cool_database"
    abort
  end

  set_rails_config_for(db)
  Rake::Task[task_to_invoke].invoke
end

def set_rails_config_for(db)
  paths = Rails.application.config.paths
  paths.add "config/database", :with => File.join(db, "db/config.yml")
  paths.add "db/migrate", :with => File.join(db, "db/migrate")
  paths.add "db/seeds", :with => File.join(db, "db/seeds.rb")
  paths.add "db/schema", :with => File.join(db, "db/schema.rb")
  ENV['DB_STRUCTURE'] = File.join(db, "db/structure.sql")

  #for use in configurator initialize
  ENV["DB_NAME"] = db + "/"
end

#https://github.com/rails/rails/blob/master/activerecord/lib/active_record/railties/databases.rake