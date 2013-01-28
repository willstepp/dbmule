require 'active_support/all'

module MuleMigrations

  class InternalConfigurationsProxy

    def initialize(configurations)
      @configurations = configurations
    end

    def on(config_key)
      if @configurations[config_key] && block_given?
        @configurations[config_key] = yield(@configurations[config_key]) || @configurations[config_key]
      end
      @configurations[config_key]
    end

  end

  class Configurator
    def self.load_configurations
      @mule_configs ||= Configurator.new.config
      @environments_config ||= YAML.load(ERB.new(File.read(@mule_configs)).result).with_indifferent_access
    end

    def self.environments_config
      proxy = InternalConfigurationsProxy.new(load_configurations)
      yield(proxy) if block_given?
    end

    def initialize(options = {})

      defaults = {
        :config       => "#{ENV["DB_NAME"]}db/config.yml",
        :migrate_dir  => "#{ENV["DB_NAME"]}db/migrate",
        :seeds        => "#{ENV["DB_NAME"]}db/seeds.rb",
        :schema       => "#{ENV["DB_NAME"]}db/schema.rb"
      }
      @options = load_from_file(defaults.dup) || defaults.merge(options)
      ENV['SCHEMA'] = File.expand_path(schema)
    end

    def config
      @options[:config]
    end

    def migrate_dir
      @options[:migrate_dir]
    end

    def seeds
      @options[:seeds]
    end

    def schema
      @options[:schema]
    end

    def config_for_all
      Configurator.load_configurations.dup
    end

    def config_for(environment)
      config_for_all[environment]
    end

    private

    def configuration_file
      ".mule_migrations"
    end

    def load_from_file(defaults)   
      return nil unless File.exists? configuration_file
      config = YAML.load( IO.read(configuration_file) ) 
      {
        :config       => config["config"] ? config["config"]["database"] : defaults[:config],
        :migrate_dir  => config["db"] ? config["db"]["migrate"] : defaults[:migrate_dir],
        :seeds        => config["db"] ? config["db"]["seeds"] : defaults[:seeds],
        :schema       => config["db"] ? config["db"]["schema"] : defaults[:schema]
      }
    end

  end
end
