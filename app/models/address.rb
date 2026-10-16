require "json"
require "fileutils"

class Address
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id, :name, :home_address, :work_address, :street_address, :city_name

  validates :name, :home_address, :work_address, :street_address, :city_name, presence: true
  validate :name_is_unique

  FILE_PATH = Rails.root.join("storage", "addresses.json")

  def initialize(attributes = {})
    @id = attributes[:id] || attributes["id"]
    @name = attributes[:name] || attributes["name"]
    @home_address = attributes[:home_address] || attributes["home_address"]
    @work_address = attributes[:work_address] || attributes["work_address"]
    @street_address = attributes[:street_address] || attributes["street_address"]
    @city_name = attributes[:city_name] || attributes["city_name"]
  end

  def self.all
    load_addresses
  end

  def self.find(id)
    load_addresses.find { |address| address.id == id.to_i }
  end

  def to_recycle_bin_attributes
    { "id" => id, "name" => name, "home_address" => home_address, "work_address" => work_address,
      "street_address" => street_address, "city_name" => city_name }
  end

  def self.restore_from_recycle_bin(attributes)
    address = new(attributes)
    return false unless address.valid?

    addresses = load_addresses.reject { |item| item.id == address.id }
    addresses << address
    save_addresses(addresses)
    address
  end

  def self.create(attributes)
      addresses = load_addresses
      next_id = addresses.map(&:id).max.to_i + 1
      address = new(attributes.merge(id: next_id))
      return false unless address.valid?

      addresses << address
      save_addresses(addresses)
      address
  end

  def self.lock_file_path
    Rails.root.join("storage", "addresses.lock")
  end

  def update(attributes)
    self.id = attributes[:id] if attributes.key?(:id) || attributes.key?("id")
    self.name = attributes[:name] if attributes.key?(:name) || attributes.key?("name")
    self.home_address = attributes[:home_address] if attributes.key?(:home_address) || attributes.key?("home_address")
    self.work_address = attributes[:work_address] if attributes.key?(:work_address) || attributes.key?("work_address")
    self.street_address = attributes[:street_address] if attributes.key?(:street_address) || attributes.key?("street_address")
    self.city_name = attributes[:city_name] if attributes.key?(:city_name) || attributes.key?("city_name")

    return false unless valid?

    addresses = self.class.load_addresses.map { |item| item.id == id ? self : item }
    self.class.save_addresses(addresses)
    self
  end

 def destroy
    Address.destroy(id)
  end

  def self.destroy(id)
    addresses = load_addresses
    address = addresses.find { |item| item.id == id.to_i }
    RecycleBin.store(address) if address
    addresses.reject! { |address| address.id == id.to_i }
    addresses.each_with_index { |address, index| address.id = index + 1 }
    save_addresses(addresses)
  end

  def self.where(city_name:)
    load_addresses.select { |address| address.city_name == city_name }
  end

  def city
    City.all.find { |a| a.city_name == city_name }
  end

  def self.load_addresses
    return [] unless File.exist?(FILE_PATH)

    data = JSON.parse(File.read(FILE_PATH))
    data.map { |attrs| new(attrs) }
  rescue JSON::ParserError
    []
  end

  def save
    return false unless valid?
    addresses = self.class.load_addresses
    self.id ||= addresses.map(&:id).max.to_i + 1
    addresses.reject! { |a| a.id == self.id }
    addresses << self
    self.class.save_addresses(addresses)
    true
  end

  def self.save_addresses(addresses)
    FileUtils.mkdir_p(File.dirname(FILE_PATH))
    serialized = addresses.map do |address|
      {
        id: address.id,
        name: address.name,
        home_address: address.home_address,
        work_address: address.work_address,
        street_address: address.street_address,
        city_name: address.city_name
      }
    end
    File.write(FILE_PATH, JSON.pretty_generate(serialized))
  end

  def name_is_unique
    duplicate = self.class.all.find do |address|
      address.id != id && address.name.to_s.casecmp?(name.to_s)
    end

    errors.add(:name, "has already been used") if duplicate
  end

  private
end
