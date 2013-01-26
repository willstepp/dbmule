require File.expand_path("../../../standalone_migrations", __FILE__)
#require 'standalone_migrations'
#StandaloneMigrations::Tasks.load_tasks
namespace :db do
  task :migrate_it do
    puts 'whazzup!'
    StandaloneMigrations::Tasks.load_tasks
  end

  task :migrate do
    #try to override the migrate task, accepting a database argument
    #if you can access it, set it to a global variable (or something)
    #which can then be picked up by the Configurator class
    puts 'hey, im in migrate'
  end
end