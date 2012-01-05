require 'test_helper'

class GrantsControllerTest < ActionController::TestCase
  setup do
    @grant = grants(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grants)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create grant" do
    assert_difference('Grant.count') do
      post :create, grant: @grant.attributes
    end

    assert_redirected_to grant_path(assigns(:grant))
  end

  test "should show grant" do
    get :show, id: @grant.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @grant.to_param
    assert_response :success
  end

  test "should update grant" do
    put :update, id: @grant.to_param, grant: @grant.attributes
    assert_redirected_to grant_path(assigns(:grant))
  end

  test "should destroy grant" do
    assert_difference('Grant.count', -1) do
      delete :destroy, id: @grant.to_param
    end

    assert_redirected_to grants_path
  end
end
