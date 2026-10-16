require "json"
require "fileutils"

module FileStorable
  extend ActiveSupport::Concern

  class_methods do
    def storage_file
      Rails.root.join("storage", "#{name.underscore.pluralize}.json")
    end

    def all
      load_records
    end

    def find(id)
      load_records.find { |r| r.id == id.to_i }
    end

    def where(attributes)
      load_records.select do |r|
        attributes.all? { |key, value| r.public_send(key).to_s == value.to_s }
      end
    end

    def create(attributes)
      records = load_records

      next_id = (records.map(&:id).max || 0) + 1

      record = new(attributes.merge(id: next_id))

      records << record

      save_records(records)

      record
    end

    def destroy(id)
      records = load_records.reject { |r| r.id == id.to_i }

      save_records(records)
    end

    def load_records
      return [] unless File.exist?(storage_file)

      JSON.parse(File.read(storage_file)).map { |attrs| new(attrs) }

    rescue JSON::ParserError

      []
    end

    def save_records(records)
      FileUtils.mkdir_p(File.dirname(storage_file))

      File.write(storage_file, JSON.pretty_generate(records.map(&:to_h)))
    end
  end

  def assign_attributes(attributes)
    attributes.each do |key, value|
      setter = "#{key}="

      public_send(setter, value) if respond_to?(setter)
    end
  end

  def update(attributes)
    assign_attributes(attributes)

    records = self.class.load_records.map { |r| r.id == id ? self : r }

    self.class.save_records(records)

    self
  end
end
