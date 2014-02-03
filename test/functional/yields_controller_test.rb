require 'test_helper'

class YieldsControllerTest < ActionController::TestCase
  setup do
    @yield = yields(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:yields)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create yield" do
    assert_difference('Yield.count') do
      post :create, yield: { bonus: @yield.bonus, quantity: @yield.quantity }
    end

    assert_redirected_to yield_path(assigns(:yield))
  end

  test "should show yield" do
    get :show, id: @yield
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @yield
    assert_response :success
  end

  test "should update yield" do
    put :update, id: @yield, yield: { bonus: @yield.bonus, quantity: @yield.quantity }
    assert_redirected_to yield_path(assigns(:yield))
  end

  test "should destroy yield" do
    assert_difference('Yield.count', -1) do
      delete :destroy, id: @yield
    end

    assert_redirected_to yields_path
  end
end
