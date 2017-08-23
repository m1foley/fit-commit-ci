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

  def self.with_membership_status
    select("repos.*", "memberships.admin AS admin_membership")
  end
end
