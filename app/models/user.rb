class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :repos, through: :memberships
  has_many :builds, through: :repos

  validates :username, presence: true
  validates :remember_token, presence: true
end
