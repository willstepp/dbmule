namespace :db do
  task :new_migration, :name, :database, :options do |t, args|
    name = args[:name] || ENV['name']
    db = args[:database]
    options = args[:options] || ENV['options']

    unless db
      puts "Error: must provide name of database to generate migration for."
      puts "For example: rake #{t.name} database=my_cool_database name=add_field_to_form"
      abort
    end
    
    unless name
      puts "Error: must provide name of migration to generate."
      puts "For example: rake #{t.name} name=add_field_to_form"
      abort
    end
    
    if options
      StandaloneMigrations::Generator.migration name, database, options.gsub('/', ' ')
    else
      StandaloneMigrations::Generator.migration name, database
    end
  end
end
