defmodule Stenotype.Output.Logger do
  require Logger

  def output(line, :info), do: Logger.info(line)
  def output(line, :debug), do: Logger.debug(line)
  def output(line, :notice), do: Logger.notice(line)
  def output(line, :warn), do: Logger.warn(line)
  def output(line, :error), do: Logger.error(line)

  def format(level_atom, message, timestamp, _metadata) do
    "|#{level(level_atom)}]#{fmt_timestamp(timestamp)}] #{message}\n"
  rescue
    _ -> "could not format message: #{inspect({level_atom, message, timestamp})}\n"
  end

  defp level(:debug), do: "D"
  defp level(:info), do: "I"
  defp level(:warn), do: "W"
  defp level(:warning), do: "W"
  defp level(:error), do: "E"

  defp fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 2}),
         time <- NaiveDateTime.to_time(timestamp),
         month_str <- String.pad_leading("#{timestamp.month}", 2, "0"),
         day_str <- String.pad_leading("#{timestamp.day}", 2, "0") do
      "#{month_str}/#{day_str}| #{Time.to_iso8601(time)}"
    end
  end
end
