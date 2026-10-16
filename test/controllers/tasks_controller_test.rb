require "test_helper"
require "securerandom"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    username = "test-admin-#{SecureRandom.hex(3)}"
    post create_account_path, params: { username: username, password: "password" }
    post sign_in_path, params: { username: username, password: "password" }
  end

  test "index renders the new task link and task list" do
    email = "jane.unique.#{SecureRandom.hex(3)}@example.com"
    contact = "22#{SecureRandom.random_number(10000000..99999999)}"
    Task.create(title: "Mr", first_name: "Jane", last_name: "Doe", age: 30, contact: contact, email: email, city_name: "New York")

    get tasks_path

    assert_response :success
    assert_select "a[href='#{new_task_path}']", text: /New Task/i
    assert_select "td[data-label='Full Name']", /Jane Doe/
  end

  test "show page renders task details" do
    email = "jane.detail.#{SecureRandom.hex(3)}@example.com"
    contact = "32#{SecureRandom.random_number(10000000..99999999)}"
    task = Task.create(title: "Mrs", first_name: "Jane", last_name: "Doe", age: 30, contact: contact, email: email, city_name: "New York")

    get task_path(task.id)

    assert_response :success
    assert_select "h1", /Task Details/i
    assert_select "strong", /First Name/
    assert_select ".detail-row", /Jane/
  end

  test "valid update with unchanged email and contact succeeds" do
    email = "alpha.#{SecureRandom.hex(3)}@example.com"
    contact = "44#{SecureRandom.random_number(10000000..99999999)}"
    task = Task.create(title: "Mr", first_name: "Alpha", last_name: "Bravo", age: 31, contact: contact, email: email, city_name: "Accra")
    City.create(region_code: "REG-1", city_name: "Accra", city_code: "ACC")

    patch task_path(task.id), params: { task: { title: "Mrs", first_name: "Alpha", last_name: "Bravo", age: 32, contact: contact, email: email, city_name: "Accra" } }

    assert_redirected_to tasks_path
    follow_redirect!
    assert_response :success
  end
end
