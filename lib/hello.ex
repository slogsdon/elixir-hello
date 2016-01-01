defmodule Hello do
  alias Hello.Retriever
  alias Hello.Template
  alias Hello.TemplateSource

  def new(opts \\ []) do
    destination = opts[:destination] || "."
    source = opts[:source] || "gogs:shane/elixir-hello"
    source_list = [:GitHub, :Gogs, :HTTP]
    template = opts[:template] || "new"
    name = opts[:name]
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join
    bindings = opts
    |> Keyword.put(:app, opts[:name])
    |> Keyword.put(:module, name)

    source
    |> parse_source(source_list)
    |> Retriever.read(template)
    |> Retriever.parse
    |> Template.parse(bindings)
    |> Template.prepare_files
    |> Template.execute(destination)
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
