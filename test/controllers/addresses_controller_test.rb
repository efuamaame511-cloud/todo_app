require "test_helper"
require "securerandom"

class AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    username = "test-admin-#{SecureRandom.hex(3)}"
    post create_account_path, params: { username: username, password: "password" }
    post sign_in_path, params: { username: username, password: "password" }
  end

  test "index page loads and shows address book heading" do
    get addresses_path

    assert_response :success
    assert_select "h1", /Address Book/i
  end

  test "new page loads" do
    get new_address_path

    assert_response :success
    assert_select "h1", /New Address/i
  end
end
