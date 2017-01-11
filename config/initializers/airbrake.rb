# We don't need airbrake emails in dev and test
if Rails.env.production?
  Airbrake.configure do |config|
    config.project_id = '87317'
    config.project_key = '45eb1d65ac2a60c0bab6f70d216d1dee'
  end
end
