defmodule Hello.Template do
  require EEx

  def execute({:error, _} = m), do: m
  def execute({:ok, template}) do
    {:ok, template}
  end

  def parse({:error, _} = m), do: m
  def parse({:ok, eex}), do: {:ok, EEx.eval_string(eex, [])}
end
