
# include FileStorable
require "json"
require "fileutils"
class Region
  include ActiveModel::Model
  include ActiveModel::Validations
  attr_accessor :id, :code, :region

  validates :code, :region, presence: true
  validate :code_and_region_are_unique

  FILE_PATH = Rails.root.join("storage", "regions.json")

  def initialize(attributes = {})
    @id = attributes[:id] || attributes["id"]
    @code = attributes[:code] || attributes["code"]
    @region = attributes[:region] || attributes["region"]
  end

  def to_h
    { id: id, code: code, region: region }
  end

  def to_recycle_bin_attributes
    { "id" => id, "code" => code, "region" => region }
  end

  def self.restore_from_recycle_bin(attributes)
    region = new(attributes)
    return false unless region.valid?

    regions = load_regions.reject { |item| item.id == region.id }
    regions << region
    save_regions(regions)
    region
  end

  def self.all
    load_regions
  end

  def self.find(id)
    load_regions.find { |region| region.id == id.to_i }
  end

  def self.create(attributes)
    regions = load_regions
    next_id = regions.map(&:id).max.to_i + 1
    region = new(attributes.merge(id: next_id))
    return false unless region.valid?

    regions << region
    save_regions(regions)
    region
  end

  def update(attributes)
    self.code = attributes[:code] if attributes.key?(:code) || attributes.key?("code")
    self.region = attributes[:region] if attributes.key?(:region) || attributes.key?("region")

    return false unless valid?

    regions = Region.load_regions
    index = regions.find_index { |r| r.id == id }
    regions[index] = self
    Region.save_regions(regions)
    true
  end

  def save
    return false unless valid?

    regions = self.class.load_regions

    if id.nil?
      self.id = regions.map(&:id).compact.max.to_i + 1
      regions << self
    else
      index = regions.find_index { |item| item.id == id }
      index ? regions[index] = self : regions << self
    end

    self.class.save_regions(regions)
    true
  end

  def self.destroy(id)
    regions = load_regions
    region = regions.find { |item| item.id == id.to_i }
    RecycleBin.store(region) if region
    regions.reject! { |region| region.id == id.to_i }
    regions.each_with_index { |region, index| region.id = index + 1 }
    save_regions(regions)
  end

  def cities
    City.where(region_code: code)
  end

  def code_and_region_are_unique
    duplicate = self.class.all.find do |item|
      item.id != id &&
        (item.code.to_s.casecmp?(code.to_s) || item.region.to_s.casecmp?(region.to_s))
    end

    errors.add(:base, "A region with this code or name already exists") if duplicate
  end

  private

  def self.load_regions
    return [] unless File.exist?(FILE_PATH)

    file_content = File.read(FILE_PATH)
    return [] if file_content.strip.empty?

    data = JSON.parse(file_content)
    data.map { |attributes| new(attributes) }
  end

  def self.save_regions(regions)
    FileUtils.mkdir_p(File.dirname(FILE_PATH))
    File.write(FILE_PATH, JSON.pretty_generate(regions.map(&:to_h)))
  end
end
