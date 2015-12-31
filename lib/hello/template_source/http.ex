defmodule Hello.TemplateSource.HTTP do
  defstruct url: nil,
            prefix: "http"

  defimpl Hello.TemplateSource, for: __MODULE__ do
    def template_url_base(s), do: s.url
    def list_url(_), do: nil
    def parse_path(s, path) do
      s |> Map.put(:url, s.prefix <> ":" <> (path |> Enum.join("/")))
    end
  end
end
