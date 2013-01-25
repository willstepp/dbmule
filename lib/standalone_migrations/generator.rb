# these generators are backed by rails' generators
require "rails/generators"
module StandaloneMigrations
  class Generator
    def self.migration(name, options="")
      puts "name: #{name}"
      puts "options: #{options}"

      generator_params = [name] + options.split(" ")

      puts "generator_params: #{generator_params}"

      migration_path = Rails.root.join("db/migrate")
      puts "Here are the OLD files located in the migration path: #{migration_path}"

      files = Dir.glob(File.join(migration_path, "*"))
      files.each do |f|
        puts f
      end
      
      Rails::Generators.invoke "active_record:migration", generator_params,
        :destination_root => Rails.root

      puts "Here are the NEW files located in the migration path: #{migration_path}"

      files = Dir.glob(File.join(migration_path, "*"))
      files.each do |f|
        puts f
      end
    end
  end
end
