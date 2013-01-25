# these generators are backed by rails' generators
require "rails/generators"
module StandaloneMigrations
  class Generator
    def self.migration(name, options="")
      puts "name: #{name}"
      puts "options: #{options}"

      generator_params = [name] + options.split(" ")

      puts "generator_params: #{generator_params}"
      puts "Here are the files located in Rails.root: #{Rails.root}"

      files = Dir.glob(File.join(Rails.root, "*"))
      files.each do |f|
        puts f
      end
      
      Rails::Generators.invoke "active_record:migration", generator_params,
        :destination_root => Rails.root
    end
  end
end
