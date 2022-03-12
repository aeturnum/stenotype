defmodule Stenotype.Output.Logger do
  require Logger

  alias Stenotype.Format.{
    Timestamp,
    LogLevel
  }

  @metadata [stenotype: true]

  def output(line, :info), do: Logger.info(line, Keyword.put(@metadata, :statement, line))
  def output(line, :debug), do: Logger.debug(line, Keyword.put(@metadata, :statement, line))
  def output(line, :notice), do: Logger.notice(line, Keyword.put(@metadata, :statement, line))
  def output(line, :warn), do: Logger.warn(line, Keyword.put(@metadata, :statement, line))
  def output(line, :error), do: Logger.error(line, Keyword.put(@metadata, :statement, line))

  def format(level_atom, message, timestamp, metadata) do
    if Keyword.get(metadata, :stenotype) do
      Keyword.get(metadata, :statement)
      |> Stenotype.Format.Statement.compose(timestamp)
    else
      "#{LogLevel.prefix(level_atom)}#{Timestamp.fmt_timestamp(timestamp)}] #{message}\n"
    end
  rescue
    _ -> "could not format message: #{inspect({level_atom, message, timestamp})}\n"
  end
end
