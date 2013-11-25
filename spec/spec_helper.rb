require 'bundler/setup'

require 'qipowl'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
#  config.fail_fast = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

