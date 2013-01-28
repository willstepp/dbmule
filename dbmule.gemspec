# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "dbmule"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Stepp"]
  s.date = "2013-01-28"
  s.email = "willstepp@gmail.com"
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "MIT-LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "dbmule.gemspec",
    "lib/mule_migrations.rb",
    "lib/mule_migrations/configurator.rb",
    "lib/mule_migrations/generator.rb",
    "lib/mule_migrations/minimal_railtie_config.rb",
    "lib/mule_migrations/tasks.rb",
    "lib/mule_migrations/tasks/connection.rake",
    "lib/mule_migrations/tasks/environment.rake",
    "lib/mule_migrations/tasks/mule.rake",
    "lib/tasks/mule_migrations.rb",
    "vendor/migration_helpers/MIT-LICENSE",
    "vendor/migration_helpers/README.markdown",
    "vendor/migration_helpers/init.rb",
    "vendor/migration_helpers/lib/migration_helper.rb"
  ]
  s.homepage = "http://github.com/willstepp/dbmule"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Mule is a database migration tool based upon a stand-alone version of Rails Migrations. It is customized to be used in environments with multiple existing databases and to use SQL scripts by default instead of Migrations DSL."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord>, ["~> 3.2.11"])
      s.add_runtime_dependency(%q<railties>, ["~> 3.2.11"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<activerecord>, ["~> 3.2.11"])
      s.add_dependency(%q<railties>, ["~> 3.2.11"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<activerecord>, ["~> 3.2.11"])
    s.add_dependency(%q<railties>, ["~> 3.2.11"])
  end
end

