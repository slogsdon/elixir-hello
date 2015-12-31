defmodule Hello.TemplateSource.Gogs do
  defstruct org: nil,
            repo: nil,
            host: "http://git.logsdon.io",
            prefix: "gogs"

  defimpl Hello.TemplateSource, for: __MODULE__ do
    def template_url_base(s) do
      "#{s.host}/#{s.org}/#{s.repo}/raw/master/"
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
