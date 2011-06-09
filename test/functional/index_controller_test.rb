require 'test_helper'

class IndexControllerTest < ActionController::TestCase
	test "should load homepage" do
		get :index
		assert_response :success
	end
end
