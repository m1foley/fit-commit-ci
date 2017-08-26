# GitHub Payloads represent all types of Events, most notably Pull Requests.
# https://developer.github.com/webhooks/#payloads
class GithubPayload
  def initialize(unparsed_data)
    self.data = JSON.parse(unparsed_data)
  end

  # Sent by GitHub as confirmation when establishing a webhook
  def confirmation_ping?
    data["zen"]
  end

  # PRs can be opened, closed, synchronized, etc.
  def pull_request?
    pull_request.present?
  end

  def github_repo_id
    repository["id"]
  end

  def full_repo_name
    repository["full_name"]
  end

  def private_repo?
    repository["private"]
  end

  def repository_owner_id
    owner["id"]
  end

  def repository_owner_name
    owner["login"]
  end

  def repository_owner_is_organization?
    owner["type"] == GithubApi::ORGANIZATION_TYPE
  end

  def action
    data["action"]
  end

  private

  attr_accessor :data

  def pull_request
    data.fetch("pull_request", {})
  end

  def repository
    data["repository"]
  end

  def owner
    repository["owner"]
  end
end
