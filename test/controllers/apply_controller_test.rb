require 'test_helper'

class ApplyControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
