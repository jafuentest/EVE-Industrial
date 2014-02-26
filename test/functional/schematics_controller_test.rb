require 'test_helper'

class SchematicsControllerTest < ActionController::TestCase
  setup do
    @schematic = schematics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:schematics)
  end

  test "should show schematic" do
    get :show, id: @schematic
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @schematic
    assert_response :success
  end

  test "should update schematic" do
    put :update, id: @schematic, schematic: { input: @schematic.input, output: @schematic.output, quantity: @schematic.quantity }
    assert_redirected_to schematic_path(assigns(:schematic))
  end
end
