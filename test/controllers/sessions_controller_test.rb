require "test_helper"
require "securerandom"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "root opens the sign in page" do
    get root_path

    assert_response :success
    assert_select "h1", /Welcome back/i
    assert_select "input[name='username']"
    assert_select "input[name='password']"
  end

  test "dashboard redirects to sign in without a session" do
    get tasks_path

    assert_redirected_to sign_in_path
  end

  test "valid sign in redirects to the dashboard" do
    username = "admin-#{SecureRandom.hex(3)}"
    post create_account_path, params: { username: username, password: "password" }
    post sign_in_path, params: { username: username, password: "password" }

    assert_redirected_to tasks_path
  end

  test "get sign out returns to the sign in page" do
    username = "admin-#{SecureRandom.hex(3)}"
    post create_account_path, params: { username: username, password: "password" }
    post sign_in_path, params: { username: username, password: "password" }
    get get_sign_out_path

    assert_redirected_to sign_in_path
  end
end
