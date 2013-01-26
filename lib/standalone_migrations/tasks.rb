module StandaloneMigrations
  class Tasks
    class << self
      def configure
        Deprecations.new.call
        puts "inside StandaloneMigrations.configure"
        config_database_file = Configurator.new.config
        puts config_database_file.to_yaml
        paths = Rails.application.config.paths
        paths.add "config/database", :with => config_database_file
        puts paths
      end

      def load_tasks
        puts 'hi, im in StandaloneMigrations.load_tasks'
        configure

        load "active_record/railties/databases.rake"
        MinimalRailtieConfig.load_tasks
        %w(
          connection
          environment
          overrides
          db/new_migration
        ).each do
          |task| load "standalone_migrations/tasks/#{task}.rake"
        end
      end
    end
  end

  class Tasks::Deprecations
    def call
      if File.directory?('db/migrations')
        puts "DEPRECATED move your migrations into db/migrate"
      end
    end
  end
end
