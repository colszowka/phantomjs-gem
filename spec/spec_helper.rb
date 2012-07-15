require 'rubygems'
require 'simplecov'
require 'bundler/setup'

require 'phantomjs'
require 'capybara/rspec'
require 'capybara/poltergeist'

Phantomjs.implode!

RSpec.configure do |config|
end