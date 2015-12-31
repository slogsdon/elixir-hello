defmodule Hello do
  alias Hello.Retriever
  alias Hello.Template
  alias Hello.TemplateSource

  def new(opts \\ []) do
    source = opts[:source] || "gogs:shane/elixir-hello"
    source_list = [:GitHub, :Gogs, :HTTP]
    name = opts[:name] || "new"

    source
    |> parse_source(source_list)
    |> Retriever.read(name)
    |> Retriever.parse
    |> Template.parse
    |> Template.execute
    # |> or_alert
  end

  def or_alert({:ok, _}), do: true
  def or_alert({:error, reason}) do
    raise reason |> to_string
  end

  def parse_source(source, [ts | t]) do
    template_source = [TemplateSource, ts] |> Module.safe_concat |> struct
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
