defmodule Stenotype.Format.LogLevel do
  def prefix(%{level: level}), do: "|#{level(level)}]"
  def prefix(level), do: "|#{level(level)}]"

  defp level(:debug), do: "D"
  defp level(:info), do: "I"
  defp level(:warn), do: "W"
  defp level(:warning), do: "W"
  defp level(:error), do: "E"
end
