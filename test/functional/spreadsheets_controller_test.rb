require 'test_helper'

class SpreadsheetsControllerTest < ActionController::TestCase
  test "should get mining" do
    get :mining
    assert_response :success
  end

end
