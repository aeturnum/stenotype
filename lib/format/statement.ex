defmodule Stenotype.Format.Statement do
  @moduledoc """
  This structure collects all the relevant information about a particular
  log statement. It helps store all the meta information so we can correctly
  compose it based on content and output medium.
  """
  alias Stenotype.Location

  alias Stenotype.Format.{
    Conversion,
    Timestamp,
    LogLevel
  }

  @type single_line :: any()
  @type multi_line :: list(single_line())
  @type content :: single_line() | multi_line()
  @type level :: :error | :warning | :debug | :notice | :info

  @type t :: %__MODULE__{
          location: Location.t(),
          content: content(),
          level: level()
        }

  defstruct location: nil, content: "", level: :error

  def create(loc, content, level) do
    %__MODULE__{
      location: loc,
      content: content,
      level: level
    }
  end

  # def format(level_atom, message, timestamp, _metadata) do
  #   "|#{level(level_atom)}]#{fmt_timestamp(timestamp)}] #{message}\n"
  # rescue
  #   _ -> "could not format message: #{inspect({level_atom, message, timestamp})}\n"
  # end

  def compose(stmt, timestamp) do
    level_prefix = LogLevel.prefix(stmt)
    timestamp_str = Timestamp.fmt_timestamp(timestamp)
    loc_str = Location.log_string(stmt.location)

    format_lines(stmt.content, level_prefix, loc_str, timestamp_str)
  end

  defp format_lines(content, lvl_pfx, loc_str, ts_str) when is_binary(content) do
    "#{lvl_pfx}#{loc_str}<#{ts_str}> #{content}\n"
  end

  defp format_lines(content, lvl_pfx, loc_str, ts_str) when is_list(content) do
    # want to keep width consistent
    first_prefix = "#{lvl_pfx}#{loc_str}\\<#{ts_str}> "

    rest_lines =
      content
      |> Enum.with_index()
      |> Enum.map(fn {line, idx} -> rest_lines(idx, line, lvl_pfx, loc_str) end)

    Enum.join(["#{first_prefix}" | rest_lines], "\n") <> "\n"
  end

  defp format_lines(content, lvl_pfx, loc_str, ts_str) do
    "#{lvl_pfx}#{loc_str}<#{ts_str}> #{Conversion.to_bin(content)}\n"
  end

  defp rest_lines(_idx, line, lvl_pfx, loc_str) do
    prefix = "#{lvl_pfx}#{loc_str}"

    line_str =
      cond do
        is_binary(line) -> " |#{line}"
        true -> " |#{Conversion.to_bin(line)}"
      end

    "#{prefix}#{line_str}"
  end
end
