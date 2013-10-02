require 'spec_helper'

describe IndexController do
  render_views

  describe 'GET #root' do
    it 'works' do
      get :root
      response.should be_success
    end
  end
end
