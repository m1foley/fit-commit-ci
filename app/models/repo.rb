class Repo < ApplicationRecord
  belongs_to :owner
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :github_id, uniqueness: true, presence: true,
    numericality: { greater_than: 0 }

  def organization
    name.split("/").first
  end
end
