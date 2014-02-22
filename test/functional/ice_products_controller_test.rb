require 'test_helper'

class IceProductsControllerTest < ActionController::TestCase
  setup do
    @ice_product = ice_products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ice_products)
  end

  test "should show ice_product" do
    get :show, id: @ice_product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ice_product
    assert_response :success
  end

  test "should update ice_product" do
    put :update, id: @ice_product, ice_product: { central_id: @ice_product.central_id, name: @ice_product.name, volume: @ice_product.volume }
    assert_redirected_to ice_product_path(assigns(:ice_product))
  end

  test "should destroy ice_product" do
    assert_difference('IceProduct.count', -1) do
      delete :destroy, id: @ice_product
    end

    assert_redirected_to ice_products_path
  end
end
