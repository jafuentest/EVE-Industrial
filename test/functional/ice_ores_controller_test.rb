require 'test_helper'

class IceOresControllerTest < ActionController::TestCase
  setup do
    @ice_ore = ice_ores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ice_ores)
  end

  test "should show ice_ore" do
    get :show, id: @ice_ore
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ice_ore
    assert_response :success
  end

  test "should update ice_ore" do
    put :update, id: @ice_ore, ice_ore: { central_id: @ice_ore.central_id, name: @ice_ore.name, volume: @ice_ore.volume }
    assert_redirected_to ice_ore_path(assigns(:ice_ore))
  end

  test "should destroy ice_ore" do
    assert_difference('IceOre.count', -1) do
      delete :destroy, id: @ice_ore
    end

    assert_redirected_to ice_ores_path
  end
end
