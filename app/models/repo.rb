class Repo < ApplicationRecord
  belongs_to :owner
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :github_id, uniqueness: true, presence: true,
    numericality: { greater_than: 0 }
  validates :hook_id, numericality: { greater_than: 0 }, allow_nil: true

  def organization
    name.split("/").first
  end

  def self.active
    where(active: true)
  end

  def self.with_membership_status
    select("repos.*", "memberships.admin AS admin_membership")
  end

  def self.upsert(github_id:, private:, name:, in_organization:, owner:)
    repo = find_or_initialize_by(github_id: github_id)
    attrs = {
      private: private,
      name: name,
      in_organization: in_organization,
      owner: owner
    }

    if repo.update(attrs)
      repo
    else
      Rails.logger.error("Error upserting repo: #{repo.error_messages_formatted}")
      nil
    end
  end
end
