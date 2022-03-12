defmodule Stenotype.Format do
  alias Stenotype.Location

  def format_stack_trace(), do: Enum.map(stack(), &trace_line/1) |> Enum.join("\n")

  defp trace_line(frame_info),
    do: Location.create(frame_info) |> Location.trace_string()

  defp stack() do
    with {_, list} <- Process.info(self(), :current_stacktrace) do
      # first stack is from Process
      list
      |> Enum.drop(1)
      |> Enum.filter(fn {mod, _, _, _} -> mod != __MODULE__ end)
    end
  end
end
