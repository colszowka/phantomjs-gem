require 'rubygems'
require 'simplecov'
require 'bundler/setup'

require 'phantomjs'
require 'capybara/rspec'

Phantomjs.base_root_dir = File.expand_path('../test_install', __FILE__)
Phantomjs.implode!
