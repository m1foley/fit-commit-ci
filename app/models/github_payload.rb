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

  private

  attr_accessor :data

  def pull_request
    data.fetch("pull_request", {})
  end
end
