require "json"
require "fileutils"

class Task
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id, :title,  :first_name, :last_name, :age, :contact, :email, :city_name

  validates :title, :first_name, :last_name, :age, :contact, :city_name, :email, presence: true
  validates :age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :email_and_contact_are_unique

  FILE_PATH = Rails.root.join("storage", "tasks.json")

  def initialize(attributes = {})
    @id    = attributes[:id]    || attributes["id"]
    @title = attributes[:title] || attributes["title"]
    @first_name = attributes[:first_name] || attributes["first_name"]
    @last_name  = attributes[:last_name]  || attributes["last_name"]
    @age        = attributes[:age]        || attributes["age"]
    @contact   = attributes[:contact]    || attributes["contact"]
    @email      = attributes[:email]      || attributes["email"]
    @city_name     = attributes[:city_name]      || attributes["city_name"]
  end

  def self.all
    load_tasks
  end
  def full_name
    "#{first_name} #{last_name}"
  end

  def to_recycle_bin_attributes
    { "id" => id, "title" => title, "first_name" => first_name, "last_name" => last_name,
      "age" => age, "contact" => contact, "email" => email, "city_name" => city_name }
  end

  def self.restore_from_recycle_bin(attributes)
    task = new(attributes)
    return false unless task.valid?

    tasks = load_tasks.reject { |item| item.id == task.id }
    tasks << task
    save_tasks(tasks)
    task
  end

  def self.find(id)
    load_tasks.find { |t| t.id == id.to_i }
  end

  def self.create(attributes)
    tasks = load_tasks
    next_id = tasks.map(&:id).max.to_i + 1
    task = new(attributes.merge(id: next_id))
    return false unless task.valid?

    tasks << task
    save_tasks(tasks)
    task
  end

  def update(attributes)
    new_id = attributes[:id] || attributes["id"]
    self.id = new_id.to_i if new_id
    self.title = attributes[:title] if attributes.key?(:title) || attributes.key?("title")
    self.first_name = attributes[:first_name] if attributes.key?(:first_name) || attributes.key?("first_name")
    self.last_name  = attributes[:last_name]  if attributes.key?(:last_name) || attributes.key?("last_name")
    self.age        = attributes[:age]        if attributes.key?(:age) || attributes.key?("age")
    self.contact    = attributes[:contact]    if attributes.key?(:contact) || attributes.key?("contact")
    self.email      = attributes[:email]      if attributes.key?(:email) || attributes.key?("email")
    self.city_name  = attributes[:city_name]      if attributes.key?(:city_name) || attributes.key?("city_name")

    return false unless valid?

    tasks = self.class.load_tasks.map { |t| t.id == id ? self : t }
    self.class.save_tasks(tasks)
    self
  end

  def self.destroy(id)
    task = find(id)
    RecycleBin.store(task) if task
    tasks = load_tasks.reject { |t| t.id == id.to_i }
    tasks.each_with_index { |task, index| task.id = index + 1 }
    save_tasks(tasks)
  end

  def self.where(city_name:)
    load_cities.select { |task| task.city_name == city_name }
  end

  def city
    City.all.find { |t| t.city_name == city_name }
  end

  def email_and_contact_are_unique
    current_task = self.class.find(id)
    if current_task && current_task.email.to_s.casecmp?(email.to_s) && current_task.contact.to_s == contact.to_s
      return
    end

    duplicate = self.class.all.find do |task|
      task.id != id &&
        (task.email.to_s.casecmp?(email.to_s) || task.contact.to_s == contact.to_s)
    end

    return unless duplicate

    errors.add(:base, "A task with this email or contact already exists")
  end

  private


  def self.load_tasks
    return [] unless File.exist?(FILE_PATH)

    data = JSON.parse(File.read(FILE_PATH))
    data.map { |attrs| new(attrs) }
  rescue JSON::ParserError
    []
  end

  def self.save_tasks(tasks)
    FileUtils.mkdir_p(File.dirname(FILE_PATH))
    serialized = tasks.map { |t| { id: t.id, title: t.title,  first_name: t.first_name, last_name: t.last_name, age: t.age, contact: t.contact, email: t.email, city_name: t.city_name } }
    File.write(FILE_PATH, JSON.pretty_generate(serialized))
  end
end
