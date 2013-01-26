require File.expand_path("../../../standalone_migrations", __FILE__)

namespace :mule do
  task :migrate, :db |t, args|
    db = args[:db]

    unless db
      puts "Error: must provide name of database to migrate"
      puts "For example: rake #{t.name} db=my_cool_database"
      abort
    end

    paths = Rails.application.config.paths
    paths.add "config/database", :with => File.join(db, "db/config.yml")
    paths.add "db/migrate", :with => File.join(db, "db/migrate")
    paths.add "db", :with => File.join(db, "db")

    puts paths

    Rake::Task["db:migrate"].invoke
  end

  task :new_migration do
  end

  task :rollback do
  end
end