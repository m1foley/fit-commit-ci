class PullRequest
  OPEN_ACTION = "opened".freeze
  SYNC_ACTION = "synchronize".freeze

  def initialize(github_payload)
    self.github_payload = github_payload
  end

  def opened?
    github_payload.action == OPEN_ACTION
  end

  def synchronize?
    github_payload.action == SYNC_ACTION
  end

  private

  attr_accessor :github_payload
end
