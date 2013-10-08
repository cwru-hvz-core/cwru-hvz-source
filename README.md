== CWRU HvZ

To get this running, pull down the source code and then run:

bundle install
rake db:schema:load

>> To set up SMS integration with Twilio, set the following environment variables:
  TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER
