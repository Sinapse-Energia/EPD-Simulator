require 'test_helper'

class MqttControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get connect" do
    get :connect
    assert_response :success
  end

end
