defmodule Hello.Template do
  require EEx

  @re ~r{\n?<!-- START FILE ([a-zA-Z0-9/_\-.]+) -->\n}

  def execute({:error, _} = m, _), do: m
  def execute({:ok, files}, destination) do
    files
    |> Enum.zip(Stream.iterate(destination, &(&1)))
    |> Enum.map(&create_file/1)

    {:ok, files}
  end
  defp create_file({{name, contents}, destination}) do
    path = "./" <> destination <> "/" <> name
    |> Path.expand

    path
    |> Path.dirname
    |> File.mkdir_p

    path
    |> File.write(contents, [:write])
  end

  def parse({:error, _} = m, _), do: m
  def parse({:ok, eex}, bindings) do
    {:ok, EEx.eval_string(eex, assigns: bindings)}
  end

  def prepare_files({:error, _} = m), do: m
  def prepare_files({:ok, template}) do
    files = @re
    |> Regex.scan(template, capture: :all_but_first)
    |> List.flatten
    |> Enum.map(&(String.strip(&1, ?/)))
    contents = @re
    |> Regex.split(template)
    |> Enum.filter(fn s -> s != "" end)
    {:ok, Enum.zip(files, contents)}
  end
end
