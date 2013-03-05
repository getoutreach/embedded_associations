require 'bundler'
Bundler.require(:default, :test)

ENV['RAILS_ENV'] = 'test'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'embedded_associations'
require File.expand_path("../support/app/config/environment.rb",  __FILE__)

require 'rspec/rails'

require 'support/serialization_helpers'

ActiveRecord::Migrator.migrate(File.expand_path("../support/app/db/migrate/", __FILE__))

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end