require 'test_helper'

class IceYieldsControllerTest < ActionController::TestCase
  setup do
    @ice_yield = ice_yields(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ice_yields)
  end
end
