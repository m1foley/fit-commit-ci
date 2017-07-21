module GithubApiHelper
  def stub_github_user_repos(data)
    stub_request(:get, %r(https://api\.github\.com/user/repos)).
      to_return(status: 200, body: data)
  end
end
