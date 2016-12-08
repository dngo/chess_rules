require 'bundler/setup'
Bundler.setup

require 'byebug'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.color = true
  config.mock_with :rspec do |r|
    r.syntax = [:expect, :should]
  end

end

require 'chess_rules'
#require 'yaml'
