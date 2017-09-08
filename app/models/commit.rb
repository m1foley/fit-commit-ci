# frozen_string_literal: true

# Not persisted because we can get away with creating these on-the-fly. The
# build artifacts don't need to include commit data beyond the summaries that
# are saved in the build table.
class Commit
  GIT_LOG_DATE_FORMAT = "%a %b %d %T %Y %z"

  attr_accessor :sha, :author_name, :author_email, :date, :message

  def initialize(sha, author_name, author_email, date, message)
    self.sha = sha
    self.author_name = author_name
    self.author_email = author_email
    self.date = date
    self.message = message
  end

  def self.from_remote_hash(remote_hash)
    new(
      remote_hash[:sha],
      remote_hash[:commit][:author][:name],
      remote_hash[:commit][:author][:email],
      remote_hash[:commit][:author][:date],
      remote_hash[:commit][:message]
    )
  end

  def git_log_format
    format("commit %s\nAuthor: %s <%s>\nDate: %s\n\n%s",
      sha, author_name, author_email, date.strftime(GIT_LOG_DATE_FORMAT),
      message
    )
  end
end
