require File.expand_path("../../../standalone_migrations", __FILE__)
require 'fileutils'
require 'yaml'

#these tasks reference rails migration tasks located here:
#https://github.com/rails/rails/blob/master/activerecord/lib/active_record/railties/databases.rake

namespace :mule do

  task :new_project, :db do |t, args|

    def config_template(db)
<<-eos
development:
  adapter: postgresql
  encoding: unicode
  database: #{db}_development
  pool: 5
  username:
  password:
  host:

test:
  adapter: postgresql
  encoding: unicode
  database: #{db}_test
  pool: 5
  username:
  password:
  host:

production:
  adapter: postgresql
  encoding: unicode
  database: #{db}_production
  pool: 5
  username:
  password:
  host:
eos
    end

    db = args[:db] || ENV['db']
    unless db
      puts ""
      puts "Error: must provide name of database to generate project for."
      puts "For example: rake #{t.name} db=my_cool_database"
      puts ""
      abort
    end

    project_dir = Rails.root.join(db)

    exists = File.exists? project_dir
    if !exists
      puts ""
      puts "Mule started creating database project for #{db}"

      FileUtils.mkdir(project_dir)
      puts "Mule created directory: #{db}"
      db_dir = File.join(project_dir, "db")
      FileUtils.mkdir(db_dir)
      puts "Mule created directory: #{File.join(db, "db")}"
      migrate_dir = File.join(db_dir, "migrate")
      FileUtils.mkdir(migrate_dir)
      puts "Mule created directory: #{File.join(db, "db", "migrate")}"
      sql_dir = File.join(db_dir, "sql")
      FileUtils.mkdir(sql_dir)
      puts "Mule created directory: #{File.join(db, "db", "sql")}"
      config_file = File.join(db_dir, "config.yml")
      File.open(config_file, 'w') {|f| f.write(config_template(db))}
      puts "Mule created file: #{File.join(db, "db", "config.yml")}"

      puts "Mule finished creating database project for #{db}"
      puts ""
    else
      puts ""
      puts "This database project already exists. Please choose another name."
      puts ""
      abort
    end
  end

  task :enable_migrations_on_existing_database, :db do |t, args|
    db = args[:db] || ENV['db']

    unless db
      puts ""
      puts "Error: must provide name of database"
      puts "For example: rake #{current_task.name} db=my_cool_database"
      puts ""
      abort
    end

    puts ""
    puts "Mule enabling migrations on existing database"

    #run mule:new_migration init_from_existing_schema
    migration_path = Rails.root.join(db, "db/migrate")
    old_files = Dir.glob(File.join(migration_path, "*"))
    Rake::Task["mule:new_migration"].invoke("init_from_existing_db", db)
    new_files = Dir.glob(File.join(migration_path, "*"))

    new_migration_file = StandaloneMigrations::Generator.get_new_migration_file(old_files, new_files)
    filename = File.basename(new_migration_file, ".rb")

    #run mule:migrate to insert versioning table into database
    Rake::Task["mule:migrate"].invoke(db)

    #create backup file of existing database schema
    Rake::Task["mule:structure:dump"].invoke(db)
    schema = Rails.root.join(db, "db/structure_#{ENV['RAILS_ENV']}.sql")

    #copy schema dump into generated sql up file
      #read in schema from schema
      #write schema into generated up sql script
    s = File.open(schema, "r") {|f| f.read}
    File.open(Rails.root.join(db, "db/sql/#{filename}_up.sql"), 'w') {|f| f.write(s)}

    #create drop database <db_name> and recreate to down call
      #write schema into generated up sql script
      #read in database name from config.yml for the current RAILS_ENV

    config = YAML.load_file(Rails.root.join(db, "db/config.yml"))
    db_name = config[ENV['RAILS_ENV']]["database"]
    File.open(Rails.root.join(db, "db/sql/#{filename}_down.sql"), 'w') {|f| f.write("drop database #{db_name} cascade;\ncreate database #{db_name};")}

    puts ""
    puts "Mule finished"
    puts ""
  end

  task :new_migration, :name, :db, :options do |t, args|
    name = args[:name] || ENV['name']
    db = args[:db] || ENV['db']
    options = args[:options] || ENV['options']

    unless db
      puts ""
      puts "Error: must provide name of database to generate migration for."
      puts "For example: rake #{t.name} db=my_cool_database name=add_field_to_form"
      puts ""
      abort
    end
    
    unless name
      puts ""
      puts "Error: must provide name of migration to generate."
      puts "For example: rake #{t.name} name=add_field_to_form"
      puts ""
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
    puts ""
    puts "Error: must provide name of database"
    puts "For example: rake #{current_task.name} db=my_cool_database"
    puts ""
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
  ENV['DB_STRUCTURE'] = File.join(db, "db/structure_#{ENV['RAILS_ENV']}.sql")

  #for use in configurator initialize
  ENV["DB_NAME"] = db + "/"
end