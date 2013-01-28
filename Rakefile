require 'rubygems'
require 'bundler/setup'

task :default do
  sh "rspec spec"
end

task :all do
  sh "AR='~>3.0.0' bundle update activerecord && bundle exec rake"
  sh "AR='~>3.1.0.rc4' bundle update activerecord && bundle exec rake"
end

task :specs => ["specs:nodb"]
namespace :specs do
  require 'rspec/core/rake_task'

  desc "only specs that don't use database connection"
  RSpec::Core::RakeTask.new "nodb" do |t|
  end

  desc "run alls sepcs including those which uses database"
  task :all => [:default, :nodb]
end

namespace :mule do
  task :init do
    puts 'hi from mule init!'
  end
end

begin
  require 'jeweler'
rescue LoadError => e
  $stderr.puts "Jeweler, or one of its dependencies, is not available:"
  $stderr.puts "#{e.class}: #{e.message}"
  $stderr.puts "Install it with: sudo gem install jeweler"
else
  Jeweler::Tasks.new do |gem|
    gem.name = 'dbmule'
    gem.summary = "Mule is a database migration tool based upon a stand-alone version of Rails Migrations. It is customized to be used in environments with multiple existing databases and to use SQL scripts by default instead of Migrations DSL."
    gem.email = "willstepp@gmail.com"
    gem.homepage = "http://github.com/willstepp/dbmule"
    gem.authors = ["Daniel Stepp"]
  end

  Jeweler::GemcutterTasks.new
end
