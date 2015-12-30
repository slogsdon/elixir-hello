defmodule Hello do
  defprotocol TemplateSource do
    def template_url_base(source)
    def list_url(source)
  end

  defmodule TemplateSource.GitHub do
    defstruct org: nil,
              repo: nil,
              prefixes: ["gh:"]

    defimpl TemplateSource, for: __MODULE__ do
      def template_url_base(s) do
        "https://raw.githubusercontent.com/#{s.org}/#{s.repo}/master/"
      end
      def list_url(s) do
        "https://api.github.com/repos/#{s.org}/#{s.repo}/contents/"
      end
    end
  end
  defmodule TemplateSource.Gogs do
    defstruct org: nil,
              repo: nil,
              host: "http://git.logsdon.io",
              prefixes: ["gogs:"]

    defimpl TemplateSource, for: __MODULE__ do
      def template_url_base(s) do
        "#{s.host}/#{s.org}/#{s.repo}/raw/master/"
      end
      def list_url(s) do
        "https://api.github.com/repos/#{s.org}/#{s.repo}/contents/"
      end
    end
  end

  defmodule Template do
    defstruct name: nil,
              source: nil
  end

  def new(opts \\ []) do
    source = opts[:source] || "gogs:shane/elixir-hello"
    source_list = [Hello.TemplateSource.GitHub, Hello.TemplateSource.Gogs]
    name = opts[:name] || "new"
    source
    |> parse_source(source_list)
    |> read_template(name)
  end

  def read_template({:error, _} = m, _), do: m
  def read_template(template, name) do
    base = template |> TemplateSource.template_url_base
    request = {base <> name <> ".eex" |> to_char_list, []}
    :httpc.request(:get, request, [], [])
  end

  def parse_source(source, []) do
    {:error, "unknown source '#{source}'"}
  end
  def parse_source(source, [ts | t]) do
    template_source = ts |> struct
    prefix = template_source |> Map.get(:prefixes) |> hd
    if source |> String.starts_with?(prefix) do
      source
      |> String.replace(prefix, "")
      |> String.split("/")
      |> (fn [org, repo] ->
        template_source
        |> Map.put(:org, org)
        |> Map.put(:repo, repo)
      end).()
    else
      parse_source(source, t)
    end
  end
end
