require "json"
require "fileutils"
require "securerandom"

class RecycleBin
  RETENTION_PERIOD = 10.minutes
  FILE_PATH = Rails.root.join("storage", "recycle_bin.json")

  def self.store(record)
    entries = active_entries
    entries << {
      "id" => SecureRandom.uuid,
      "type" => record.class.name,
      "record_id" => record.id,
      "attributes" => record.to_recycle_bin_attributes,
      "deleted_at" => Time.current.iso8601
    }
    save_entries(entries)
  end

  def self.all
    active_entries.sort_by { |entry| entry["deleted_at"] }.reverse
  end

  def self.restore(id)
    entries = active_entries
    entry = entries.find { |item| item["id"] == id }
    return false unless entry

    model = entry["type"].constantize
    restored = model.restore_from_recycle_bin(entry["attributes"])
    return false unless restored

    save_entries(entries.reject { |item| item["id"] == id })
    true
  end

  private

  def self.active_entries
    entries = load_entries
    fresh_entries = entries.select do |entry|
      Time.iso8601(entry["deleted_at"]) > RETENTION_PERIOD.ago
    rescue ArgumentError, TypeError
      false
    end
    save_entries(fresh_entries) if fresh_entries.length != entries.length
    fresh_entries
  end

  def self.load_entries
    return [] unless File.exist?(FILE_PATH)

    JSON.parse(File.read(FILE_PATH))
  rescue JSON::ParserError
    []
  end

  def self.save_entries(entries)
    FileUtils.mkdir_p(File.dirname(FILE_PATH))
    File.write(FILE_PATH, JSON.pretty_generate(entries))
  end
end
