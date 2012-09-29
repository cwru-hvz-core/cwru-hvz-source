# Load the rails application
require File.expand_path('../application', __FILE__)

require 'json'
require 'casclient'
require 'casclient/frameworks/rails/filter'
require 'googlevoiceapi'
require 'hassle'
require './lib/update_game_state.rb'
require './lib/send_notification.rb'
require 'google_chart'

Sass::Plugin.options[:template_location] = { "/app/stylesheets" => "public/stylesheets" }

CASClient::Frameworks::Rails::Filter.configure(
      :cas_base_url => "https://login.case.edu/cas/"
    )

# Initialize the rails application
Hvz::Application.initialize!
