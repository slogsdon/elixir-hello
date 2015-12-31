defmodule Hello.TemplateSource.GitHub do
  defstruct org: nil,
            repo: nil,
            prefix: "gh",
            headers: [{'accept', 'application/vnd.github.v3+json'}]

  defimpl Hello.TemplateSource, for: __MODULE__ do
    def template_url_base(s) do
      "https://raw.githubusercontent.com/#{s.org}/#{s.repo}/master/"
    end
    def list_url(s) do
      "https://api.github.com/repos/#{s.org}/#{s.repo}/contents/"
    end
    def parse_path(s, [org, repo]) do
      s
      |> Map.put(:org, org)
      |> Map.put(:repo, repo)
    end
  end
end
