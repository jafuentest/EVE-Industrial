require 'test_helper'

class OresControllerTest < ActionController::TestCase
  setup do
    @ore = ores(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ores)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ore" do
    assert_difference('Ore.count') do
      post :create, ore: { name: @ore.name, refine: @ore.refine, volume: @ore.volume }
    end

    assert_redirected_to ore_path(assigns(:ore))
  end

  test "should show ore" do
    get :show, id: @ore
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ore
    assert_response :success
  end

  test "should update ore" do
    put :update, id: @ore, ore: { name: @ore.name, refine: @ore.refine, volume: @ore.volume }
    assert_redirected_to ore_path(assigns(:ore))
  end

  test "should destroy ore" do
    assert_difference('Ore.count', -1) do
      delete :destroy, id: @ore
    end

    assert_redirected_to ores_path
  end
end
