class User < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :repos, through: :memberships

  validates :username, presence: true
  validates :remember_token, presence: true
end
