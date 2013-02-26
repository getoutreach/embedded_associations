require 'bundler'
Bundler.require(:default, :test)

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'embedded_associations'
require File.expand_path("../support/app/config/environment.rb",  __FILE__)

require 'rspec/rails'

require 'support/serialization_helpers'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end