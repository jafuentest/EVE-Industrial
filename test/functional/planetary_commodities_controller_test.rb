require 'test_helper'

class PlanetaryCommoditiesControllerTest < ActionController::TestCase
  setup do
    @planetary_commodity = planetary_commodities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:planetary_commodities)
  end

  test "should show planetary_commodity" do
    get :show, id: @planetary_commodity
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @planetary_commodity
    assert_response :success
  end

  test "should update planetary_commodity" do
    put :update, id: @planetary_commodity, planetary_commodity: { central_id: @planetary_commodity.central_id, name: @planetary_commodity.name, quantity: @planetary_commodity.quantity, volume: @planetary_commodity.volume }
    assert_redirected_to planetary_commodity_path(assigns(:planetary_commodity))
  end
end
