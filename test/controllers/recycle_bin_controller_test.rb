require "test_helper"
require "securerandom"

class RecycleBinControllerTest < ActionDispatch::IntegrationTest
  setup do
    username = "bin-admin-#{SecureRandom.hex(3)}"
    post create_account_path, params: { username: username, password: "password" }
    post sign_in_path, params: { username: username, password: "password" }
  end

  test "deleted tasks can be restored from the recycle bin" do
    email = "bin.#{SecureRandom.hex(3)}@example.com"
    task = Task.create(title: "Mr", first_name: "Bin", last_name: "User", age: 28,
                      contact: "55#{SecureRandom.random_number(10000000..99999999)}",
                      email: email, city_name: "Accra")

    delete task_path(task.id)
    assert_nil Task.find(task.id)

    get recycle_bin_path
    assert_response :success
    assert_select "td", text: "Task"
    entry = RecycleBin.all.find { |item| item["record_id"] == task.id }

    post restore_recycle_bin_path(entry["id"])

    assert_redirected_to recycle_bin_path
    restored_task = Task.find(task.id)
    assert_equal "Bin", restored_task.first_name
    assert_equal email, restored_task.email
  end
end
