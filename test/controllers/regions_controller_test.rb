require "test_helper"
require "securerandom"

class RegionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    username = "test-admin-#{SecureRandom.hex(3)}"
    post create_account_path, params: { username: username, password: "password" }
    post sign_in_path, params: { username: username, password: "password" }
  end

  test "duplicate region returns an already-created alert" do
    code = "TEST-#{SecureRandom.hex(3)}"
    region_name = "Test Region #{SecureRandom.hex(3)}"
    existing = Region.create(code: code, region: region_name)

    post regions_path, params: { region: { code: code, region: region_name } }

    assert existing
    assert_response :unprocessable_entity
    assert_select ".form-alert", /already created/i
    Region.destroy(existing.id)
  end
end
