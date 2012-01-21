require 'test_helper'

class AccountSettingsControllerTest < ActionController::TestCase
  setup do
    @account_setting = account_settings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:account_settings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create account_setting" do
    assert_difference('AccountSetting.count') do
      post :create, account_setting: @account_setting.attributes
    end

    assert_redirected_to account_setting_path(assigns(:account_setting))
  end

  test "should show account_setting" do
    get :show, id: @account_setting.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @account_setting.to_param
    assert_response :success
  end

  test "should update account_setting" do
    put :update, id: @account_setting.to_param, account_setting: @account_setting.attributes
    assert_redirected_to account_setting_path(assigns(:account_setting))
  end

  test "should destroy account_setting" do
    assert_difference('AccountSetting.count', -1) do
      delete :destroy, id: @account_setting.to_param
    end

    assert_redirected_to account_settings_path
  end
end
