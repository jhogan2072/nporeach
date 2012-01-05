require 'test_helper'

class PortletsControllerTest < ActionController::TestCase
  setup do
    @portlet = portlets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:portlets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create portlet" do
    assert_difference('Portlet.count') do
      post :create, portlet: @portlet.attributes
    end

    assert_redirected_to portlet_path(assigns(:portlet))
  end

  test "should show portlet" do
    get :show, id: @portlet.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @portlet.to_param
    assert_response :success
  end

  test "should update portlet" do
    put :update, id: @portlet.to_param, portlet: @portlet.attributes
    assert_redirected_to portlet_path(assigns(:portlet))
  end

  test "should destroy portlet" do
    assert_difference('Portlet.count', -1) do
      delete :destroy, id: @portlet.to_param
    end

    assert_redirected_to portlets_path
  end
end
