require File.expand_path("../../../standalone_migrations", __FILE__)

namespace :mule do
  task :migrate, :db do |t, args|
    database = args[:db] || ENV[
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

    Rake::Task["db:migrate"].invoke
  end

  task :new_migration do
  end

  task :rollback do
    Rake::Task["db:rollback"].invoke
  end
end

#https://github.com/rails/rails/blob/master/activerecord/lib/active_record/railties/databases.rake