# Load the rails application
require File.expand_path('../application', __FILE__)

require './lib/update_game_state.rb'
require './lib/send_notification.rb'
require 'google_chart'

# Initialize the rails application
Hvz::Application.initialize!
