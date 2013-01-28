# these generators are backed by rails' generators
require "rails/generators"

module StandaloneMigrations

  class Generator
    def self.migration(name, db, type, options="")
      generator_params = [name] + options.split(" ")

      migration_path = Rails.root.join(db, "db/migrate")

      old_files = Dir.glob(File.join(migration_path, "*"))

      Rails::Generators.invoke "active_record:migration", generator_params,
        :destination_root => Rails.root.join(db)
      new_files = Dir.glob(File.join(migration_path, "*"))

      new_migration_file = get_new_migration_file(old_files, new_files)

      if new_migration_file and type == 'sql'
        filename = File.basename(new_migration_file, ".rb")

        sql_scripts = create_sql_scripts(db, filename)

        #update migration file contents with sql execution code
        nmf = File.open(new_migration_file, "r") {|f| f.read}
        updated_nmf = inject_sql_execution_code_into_migration(nmf, filename, sql_scripts)
        File.open(new_migration_file, 'w') {|f| f.write(updated_nmf)}
      end
    end

    def self.get_new_migration_file(old_files, new_files)
      nf = []
      new_files.each do |f|
        if !old_files.include? f
          nf << f
        end
      end
      nf.count > 0 ? nf.first : nil
    end

    private

    def self.create_sql_scripts(db, filename)
      sql_path = Rails.root.join(db, "db/sql")
      up_script = File.join(sql_path, "#{filename}_up.sql")
      down_script = File.join(sql_path, "#{filename}_down.sql")

      File.open(up_script, 'w') {|f| f.write("--SQL up code for migration (#{filename}) goes here")}
      puts ""
      puts "Mule created: #{filename}_up.sql"
      File.open(down_script, 'w') {|f| f.write("--SQL down code for migration (#{filename}) goes here")}
      puts "Mule created: #{filename}_down.sql"

      puts "Mule put the scripts here: #{File.join(db, "db/sql")}"
      puts ""

      { :up => up_script, :down => down_script }
    end

    def self.inject_sql_execution_code_into_migration(nmf, filename, sql_scripts)

      ci = nmf.index('class')+5
      lti = nmf.index('<')-1
      length = (lti - ci)
      classname = nmf.slice(ci, length).strip

<<-eos
class #{classname} < ActiveRecord::Migration
  def up
    sql = File.open('#{sql_scripts[:up]}', 'r') {|f| f.read}
    execute(sql)
  end

  def down
    sql = File.open('#{sql_scripts[:down]}', 'r') {|f| f.read}
    execute(sql)
  end
end
eos
    end
  end
end