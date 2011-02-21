# Load the rails application
require File.expand_path('../application', __FILE__)

require 'casclient'
require 'casclient/frameworks/rails/filter'
require 'googlevoiceapi'
require './lib/update_game_state.rb'
require 'google_chart'

CASClient::Frameworks::Rails::Filter.configure(
      :cas_base_url => "https://login.case.edu/cas/"
    )

# Initialize the rails application
Hvz::Application.initialize!
