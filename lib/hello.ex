defmodule Hello do
  defprotocol TemplateSource do
    def template_url_base(source)
    def list_url(source)
    def parse_path(source, path)
  end

  defmodule TemplateSource.HTTP do
    defstruct url: nil
  end
  defmodule TemplateSource.GitHub do
    defstruct org: nil,
              repo: nil,
              prefix: "gh"

    defimpl TemplateSource, for: __MODULE__ do
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
  defmodule TemplateSource.Gogs do
    defstruct org: nil,
              repo: nil,
              host: "http://git.logsdon.io",
              prefix: "gogs"

    defimpl TemplateSource, for: __MODULE__ do
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

  defmodule Template do
    defstruct name: nil,
              source: nil
  end

  def new(opts \\ []) do
    require EEx
    source = opts[:source] || "gogs:shane/elixir-hello"
    source_list = [Hello.TemplateSource.GitHub, Hello.TemplateSource.Gogs]
    name = opts[:name] || "new"
    source
    |> parse_source(source_list)
    |> read_template(name)
    |> parse_response
    |> (fn
      {:error, _} = m -> m
      {:ok, eex} -> {:ok, EEx.eval_string(eex, [])}
    end).()
  end

  def parse_response({:error, _} = m), do: m
  def parse_response({:ok, {{_,200,_}, _headers, body}}) do
    {:ok, body |> to_string}
  end
  def parse_response({:ok, {{_,404,_}, _headers, _body}}) do
    {:error, :template_not_found}
  end
  def parse_response(_) do
    {:error, :unknown_http_error}
  end

  def read_template({:error, _} = m, _), do: m
  def read_template({:ok, %Hello.TemplateSource.HTTP{} = template}, _) do
    request = {template.url |> to_char_list, []}
    :httpc.request(:get, request, [], [])
  end
  def read_template({:ok, template}, name) do
    base = template |> TemplateSource.template_url_base
    request = {base <> name <> ".eex" |> to_char_list, []}
    :httpc.request(:get, request, [], [])
  end

  def parse_source("http" <> _ = source, _) do
    Hello.TemplateSource.HTTP
    |> struct
    |> Map.put(:url, source)
  end
  def parse_source(source, [ts | t]) do
    template_source = ts |> struct
    prefix = (template_source |> Map.get(:prefix)) <> ":"
    if source |> String.starts_with?(prefix) do
      path = source
             |> String.replace(prefix, "")
             |> String.split("/")
      {:ok, TemplateSource.parse_path(template_source, path)}
    else
      parse_source(source, t)
    end
  end
  def parse_source(_source, []) do
    {:error, :unknown_template_source}
  end
end
