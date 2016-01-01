defmodule Mix.Tasks.Hello do
  @moduledoc """
  Generates project files from templates

  ## Usage

      mix hello NAME [DESTINATION] [options]

  ## Options

  - `param`
  - `source`
  - `template`
  """
  @shortdoc "Generates project files from templates"
  @needed_apps [:crypto, :asn1, :public_key, :ssl, :inets]

  use Mix.Task

  def run(args) do
    opts = [
      switches: [param: :keep, source: :string, template: :string],
      aliases:  [p: :param, s: :source, t: :template]
    ]
    ensure_all_started!

    args
    |> OptionParser.parse(opts)
    |> inject_args
    |> merge_param_values
    |> Keyword.update!(:param, &params_to_map/1)
    |> Hello.new
    |> or_alert
  end

  def inject_args(opts)
  def inject_args({_, [], _}), do: raise Mix.Error, message: "expected NAME to be given"
  def inject_args({flags, [name | rest], _}) do
    name |> check_name!

    unless match? [_dest | _], rest do
      rest = ["." | rest]
    end

    flags
    |> Keyword.put(:name, name)
    |> Keyword.put(:destination, rest |> hd)
  end

  def merge_param_values(kw) do
    kw |> Keyword.put(:param, kw |> Keyword.get_values(:param))
  end

  def params_to_map(params) when params |> is_list do
    params
    |> Stream.map(fn p -> p |> String.split(":", parts: 2) end)
    |> Stream.map(fn [k,v] -> {k,v} end)
    |> Enum.into(%{})
  end
  def params_to_map(params), do: params

  def or_alert({:ok, _}), do: :ok
  def or_alert({:error, reason}) do
    raise reason |> to_string
  end

  defp ensure_all_started! do
    @needed_apps |> Enum.map(&:application.ensure_started/1)
  end

  defp check_name!(name) do
    unless name =~ ~r/^[a-z][\w_]+$/ do
      raise Mix.Error, message: "application name must start with a letter and have only lowercase letters, numbers and underscore"
    end
  end
end
