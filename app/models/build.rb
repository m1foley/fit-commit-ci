class Build < ApplicationRecord
  belongs_to :repo
  belongs_to :user

  validates :repo, :head_sha, presence: true
  validates :pull_request_number, numericality: { greater_than: 0 },
    allow_nil: true
  validates :warning_count, :error_count, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
end
