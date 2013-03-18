require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
      :cas_base_url => "https://login.case.edu/cas/"
)
