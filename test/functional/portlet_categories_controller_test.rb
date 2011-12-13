require 'test_helper'

class PortletCategoriesControllerTest < ActionController::TestCase
  setup do
    @portlet_category = portlet_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:portlet_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create portlet_category" do
    assert_difference('PortletCategory.count') do
      post :create, portlet_category: @portlet_category.attributes
    end

    assert_redirected_to portlet_category_path(assigns(:portlet_category))
  end

  test "should show portlet_category" do
    get :show, id: @portlet_category.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @portlet_category.to_param
    assert_response :success
  end

  test "should update portlet_category" do
    put :update, id: @portlet_category.to_param, portlet_category: @portlet_category.attributes
    assert_redirected_to portlet_category_path(assigns(:portlet_category))
  end

  test "should destroy portlet_category" do
    assert_difference('PortletCategory.count', -1) do
      delete :destroy, id: @portlet_category.to_param
    end

    assert_redirected_to portlet_categories_path
  end
end
