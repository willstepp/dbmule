require File.expand_path("../../../mule_migrations", __FILE__)
namespace :mule do
  task :connection do
    configurator = MuleMigrations::Configurator.new
    ActiveRecord::Base.establish_connection configurator.config_for(Rails.env)
  end
end
