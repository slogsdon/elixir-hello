defmodule Hello.Retriever do
  alias Hello.TemplateSource

  defmodule HTTPC do
    @moduledoc false
    def request(method, {url, headers}) do
      :httpc.request(method, {url |> to_char_list, headers}, [], [])
    end
  end

  def parse({:error, _} = m), do: m
  def parse({:ok, {{_,200,_}, _headers, body}}) do
    {:ok, body |> to_string}
  end
  def parse({:ok, {{_,404,_}, _headers, _body}}) do
    {:error, :template_not_found}
  end
  def parse(_) do
    {:error, :unknown_http_error}
  end

  @default_headers [{'user-agent', 'Elixir Hello'}]

  def read(maybe_source, name, client \\ HTTPC)
  def read({:error, _} = m, _, _), do: m
  def read({:ok, source}, name, client) do
    base = source |> TemplateSource.template_url_base
    headers = get_headers(source)
    base <> name <> ".eex" |> make_request(headers, client)
  end

  defp make_request(url, headers, client) do
    client.request(:get, {url, headers})
  end
  defp get_headers(source, defaults \\ @default_headers) do
    if source |> Map.has_key?(:headers) do
      defaults ++ source.headers
    else
      defaults
    end
  end
end
