class ReviewPullRequest
  def initialize(github_payload)
    self.github_payload = github_payload
  end

  def call
    Rails.logger.info(format("Reviewing PR: %s %s",
      github_payload.full_repo_name || "(No repo)",
      github_payload.head_sha || "(No SHA)"))
    SyncDataFromPayload.new(github_payload).call

    if !repo
      Rails.logger.info("Skipping PR: Repo not found.")
    elsif !relevant_pull_request?
      Rails.logger.info("Skipping PR: Action not relevant.")
    else
      Rails.logger.info("Starting PR review")
      publish_pending_status
      build = create_build || return
      warning_count, error_count = *ReviewBuild.new(build).call
      publish_success_status(warning_count, error_count)
    end
  end

  private

  attr_accessor :github_payload

  def repo
    @repo ||= Repo.active.find_by(github_id: github_payload.github_repo_id)
  end

  # can be the unpersisted default FCCI user
  def repo_user
    @repo_user ||= UserByRepo.new(repo).call
  end

  def pull_request
    @pull_request ||= PullRequest.new(github_payload)
  end

  def relevant_pull_request?
    pull_request.opened? || pull_request.synchronize?
  end

  def status_publisher
    @status_publisher ||= PublishStatus.new(
      github_payload.full_repo_name,
      github_payload.head_sha,
      repo_user.github_token
    )
  end

  delegate :publish_pending_status, :publish_success_status,
    :publish_error_status, to: :status_publisher

  def create_build
    build = repo.builds.build(
      pull_request_number: github_payload.pull_request_number,
      head_sha: github_payload.head_sha,
      user: repo_user # nil if default FCCI user
    )

    if build.save
      build
    else
      error_message = build.error_messages_formatted
      Rails.logger.error("Error creating build: #{error_message}")
      publish_error_status(error_message)
      nil
    end
  end
end
