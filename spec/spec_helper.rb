require 'bundler/setup'
require 'simplecov'
require 'vcr'

SimpleCov.start do
  add_group 'Lib', 'lib'
  add_group 'Tests', 'spec'
end
SimpleCov.minimum_coverage 90

VCR.configure do |config|
  config.cassette_library_dir = 'vcr_cassettes'
  config.hook_into :webmock

  %w[TNT_USERNAME TNT_PASSWORD TNT_ACCOUNT_ID].each do |pkey|
    ENV[pkey] ||= 'secret'
    config.filter_sensitive_data("~#{pkey}~") { ENV[pkey] }
  end
end

require 'tnt'
require 'ffaker'

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
