# encoding: utf-8
require 'phantomjs'
require 'capybara/poltergeist'
Phantomjs.path # Force install on require
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end
