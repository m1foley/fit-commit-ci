module GithubApiHelper
  def stub_github_user_repos(data)
    stub_request(:get, %r(https://api\.github\.com/user/repos)).
      to_return(status: 200, body: data)
  end

  def stub_github_create_hook(repo)
    hook_id = Random.rand(999_999)
    stub_request(:post, "https://api.github.com/repos/#{repo.name}/hooks").
      to_return(
        status: 201,
        body: "{\"id\":#{hook_id}}",
        headers: { "Content-Type" => "application/json; charset=utf-8" }
      )
    hook_id
  end

  def stub_github_create_hook_fail(repo, error_message)
    stub_request(:post, "https://api.github.com/repos/#{repo.name}/hooks").
      to_return(status: 400, body: error_message)
  end
end
