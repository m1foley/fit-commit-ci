class Owner < ApplicationRecord
  has_many :repos
  validates :github_id, uniqueness: true, presence: true
  validates :name, presence: true

  def self.upsert(github_id:, name:, organization:)
    owner = find_or_initialize_by(github_id: github_id)
    attrs = { name: name, organization: organization }

    if owner.update(attrs)
      owner
    else
      Rails.logger.error("Error upserting owner: #{owner.error_messages_formatted}")
      nil
    end
  end
end
