require "test_helper"

class CommitTest < ActiveSupport::TestCase
  def remote_hash
    {
      sha: "abc123",
      commit: {
        author: {
          name: "Fname Lname",
          email: "foo@bar.com",
          date: Time.new(2017, 8, 24, 5, 20, 3, 0)
        },
        message: "This is a commit message\n\nHello."
      }
    }
  end

  def test_from_remote_hash
    commit = Commit.from_remote_hash(remote_hash)
    assert_equal "abc123", commit.sha
    assert_equal "Fname Lname", commit.author_name
    assert_equal "foo@bar.com", commit.author_email
    assert_equal Time.new(2017, 8, 24, 5, 20, 3, 0), commit.date
  end

  def test_git_log_format
    expected_log_format = <<~LOG
      commit abc123
      Author: Fname Lname <foo@bar.com>
      Date: Thu Aug 24 05:20:03 2017 +0000

      This is a commit message

      Hello.
    LOG
    expected_log_format.strip!

    commit = Commit.from_remote_hash(remote_hash)
    assert_equal expected_log_format, commit.git_log_format
  end
end
