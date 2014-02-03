require 'test_helper'

class VariationsControllerTest < ActionController::TestCase
  setup do
    @variation = variations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:variations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create variation" do
    assert_difference('Variation.count') do
      post :create, variation: { name: @variation.name }
    end

    assert_redirected_to variation_path(assigns(:variation))
  end

  test "should show variation" do
    get :show, id: @variation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @variation
    assert_response :success
  end

  test "should update variation" do
    put :update, id: @variation, variation: { name: @variation.name }
    assert_redirected_to variation_path(assigns(:variation))
  end

  test "should destroy variation" do
    assert_difference('Variation.count', -1) do
      delete :destroy, id: @variation
    end

    assert_redirected_to variations_path
  end
end
