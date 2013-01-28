module MuleMigrations
  class Tasks
    class << self
      def configure
        Deprecations.new.call
        config_database_file = Configurator.new.config

        paths = Rails.application.config.paths
        paths.add "config/database", :with => config_database_file
      end

      def load_tasks
        configure

        load "active_record/railties/databases.rake"
        MinimalRailtieConfig.load_tasks
        %w(
          connection
          environment
          mule
        ).each do
          |task| load "mule_migrations/tasks/#{task}.rake"
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
