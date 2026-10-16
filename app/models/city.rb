require "json"
require "fileutils"
class City
  include ActiveModel::Model
  include ActiveModel::Validations
  attr_accessor :id, :region_code, :city_name, :city_code

  validates :region_code, :city_name, :city_code, presence: true
  validate :city_name_and_code_are_unique

  FILE_PATH = Rails.root.join("storage", "cities.json")

  def initialize(attributes = {})
    @id = attributes[:id] || attributes["id"]
    @region_code = attributes[:region_code] || attributes["region_code"]
    @city_name = attributes[:city_name] || attributes["city_name"]
    @city_code = attributes[:city_code] || attributes["city_code"]
  end

  def to_h
    { id: id, region_code: region_code, city_name: city_name, city_code: city_code }
  end

  def to_recycle_bin_attributes
    { "id" => id, "region_code" => region_code, "city_name" => city_name, "city_code" => city_code }
  end

  def self.restore_from_recycle_bin(attributes)
    city = new(attributes)
    return false unless city.valid?

    cities = load_cities.reject { |item| item.id == city.id }
    cities << city
    save_cities(cities)
    city
  end

  def self.all
    load_cities
  end

  def self.find(id)
    load_cities.find { |city| city.id == id.to_i }
  end

  def self.create(attributes)
    cities = load_cities
    next_id = cities.map(&:id).max.to_i + 1
    city = new(attributes.merge(id: next_id))
    return false unless city.valid?

    cities << city
    save_cities(cities)
    city
  end

  def update(attributes)
 new_id = attributes[:id] || attributes["id"]
  self.id = new_id.to_i if new_id
    self.region_code = attributes[:region_code] if attributes.key?(:region_code) || attributes.key?("region_code")
    self.city_name = attributes[:city_name] if attributes.key?(:city_name) || attributes.key?("city_name")
    self.city_code = attributes[:city_code] if attributes.key?(:city_code) || attributes.key?("city_code")

    return false unless valid?

    cities = City.load_cities
    index = cities.find_index { |c| c.id == id }
      return false unless index

    cities[index] = self
    City.save_cities(cities)
    true
  end


  def save
    return false unless valid?

    cities = City.load_cities

    if id.nil?
      next_id = cities.map(&:id).compact.max.to_i + 1
      self.id = next_id
      cities << self
    else
      index = cities.find_index { |c| c.id == id }
      index ? cities[index] = self : cities << self
    end

    City.save_cities(cities)
    true
  end

 def destroy
    City.destroy(id)
  end

  def self.destroy(id)
    cities = load_cities
    city = cities.find { |item| item.id == id.to_i }
    RecycleBin.store(city) if city
    cities.reject! { |city| city.id == id.to_i }
    cities.each_with_index { |city, index| city.id = index + 1 }
    save_cities(cities)
  end

  def self.where(region_code:)
    load_cities.select { |city| city.region_code == region_code }
  end

  def region
    Region.all.find { |r| r.code == region_code }
  end

  def city_name_and_code_are_unique
    duplicate = self.class.all.find do |item|
      item.id != id &&
        (item.city_name.to_s.casecmp?(city_name.to_s) || item.city_code.to_s.casecmp?(city_code.to_s))
    end

    errors.add(:base, "A city with this name or code already exists") if duplicate
  end

  private

  def self.load_cities
    return [] unless File.exist?(FILE_PATH)

    file_content = File.read(FILE_PATH)
    return [] if file_content.strip.empty?

    data = JSON.parse(file_content)
    data.map { |attributes| new(attributes) }
  end

  def self.save_cities(cities)
    FileUtils.mkdir_p(File.dirname(FILE_PATH))
    File.write(FILE_PATH, JSON.pretty_generate(cities.map(&:to_h)))
  end
end
