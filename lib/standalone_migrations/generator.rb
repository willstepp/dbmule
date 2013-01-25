# these generators are backed by rails' generators
require "rails/generators"
module StandaloneMigrations
  class Generator
    def self.migration(name, options="")
      puts "Creating migration"

      generator_params = [name] + options.split(" ")

      migration_path = Rails.root.join("db/migrate")

      old_files = Dir.glob(File.join(migration_path, "*"))
      Rails::Generators.invoke "active_record:migration", generator_params,
        :destination_root => Rails.root
      new_files = Dir.glob(File.join(migration_path, "*"))

      new_migration_file = get_new_migration_file(old_files, new_files)
      filename = File.basename(new_migration_file, ".rb")

      sql_scripts = create_sql_scripts(filename)

      #update migration file contents with sql execution code
      nmf = File.open(new_migration_file, "r") {|f| f.read}
      updated_nmf = inject_sql_execution_code_into_migration(nmf, filename, sql_scripts)
      File.open(new_migration_file, 'w') {|f| f.write(updated_nmf)}

      puts "Finished creating migration"
    end

    private

    def self.get_new_migration_file(old_files, new_files)
      nf = []
      new_files.each do |of|
        if !old_files.include? of
          nf << of
        end
      end
      nf.count > 0 ? nf.first : nil
    end

    def self.create_sql_scripts(filename)
      sql_path = Rails.root.join("db/sql")
      up_script = File.join(sql_path, "#{filename}_up.sql")
      down_script = File.join(sql_path, "#{filename}_down.sql")

      File.open(up_script, 'w') {|f| f.write("--SQL up code goes here")}
      File.open(down_script, 'w') {|f| f.write("--SQL down code goes here")}

      { :up => up_script, :down => down_script }
    end

    def self.inject_sql_execution_code_into_migration(nmf, filename, sql_scripts)

      ci = nmf.index('class')+5
      lti = nmf.index('<')-1
      length = (lti - ci)
      classname = nmf.slice(ci, length).strip

      code <<-eos
        class #{classname} < ActiveRecord::Migration
        def up
          sql = File.open('#{sql_scripts[:up]}', 'r') {|f| f.read}
          execute(sql)
        end
        
        def down
          sql = File.open('#{sql_scripts[:down]}', 'r') {|f| f.read}
          execute(sql)
        end
      eos
      code
    end
  end
end


#1) Get path of newly created migration file after the migration has completed
#2) Create two empty sql scripts in the sql directory with the same name
#3) Modify the newly created migration file to load and execute the sql script