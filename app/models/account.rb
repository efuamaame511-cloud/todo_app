class Account < ActiveRecord::Base
  has_secure_password

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  def self.authenticate(username, password)
    account = find_by("LOWER(username) = ?", username.to_s.strip.downcase)
    account if account&.authenticate(password)
  end
end
