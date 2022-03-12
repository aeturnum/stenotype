defmodule Stenotype.Format do
  alias Stenotype.Location

  @tab "  "
  # inspect options

  @inspect_opts [
    printable_limit: 20,
    limit: 5
  ]

  def format_stack_trace(), do: Enum.map(stack(), &trace_line/1) |> Enum.join("\n")

  def log_line(loc, line) do
    try do
      loc_str = Location.log_string(loc)

      line =
        if is_binary(line) do
          " " <> line
        else
          line
        end

      layout_log(loc_str, line)
    catch
      _ -> inspect(line)
    end
  end

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

  # handle recusive calls to making the line
  @spec layout_log(binary, any) :: binary
  def layout_log(start, [line | rest]),
    do:
      _with_pre("\n#{@tab}|", start) <>
        _with_pre("\n#{@tab}\\#{@tab}", line) <> make_rest_line(rest)

  # just wrap whatever we were passed as a backup
  def layout_log(start, line), do: _with_pre(start, line)

  def _with_pre(pre, line) when is_binary(line), do: "#{pre}#{line}"
  def _with_pre(pre, line), do: "#{pre}" <> to_bin(line)

  def make_rest_line([]), do: ""

  def make_rest_line([line | rest]),
    do: _with_pre("\n#{@tab} |#{@tab}", line) <> make_rest_line(rest)

  # wrapper for turning anything into a binary
  @spec to_bin(any()) :: binary
  # special case for these atoms
  def to_bin(nil), do: "nil"
  def to_bin(false), do: "false"
  def to_bin(true), do: "true"

  def to_bin(o) when is_list(o) do
    o
    |> Enum.map(fn item -> to_bin(item) end)
    |> Enum.join(", ")
    |> wrap_str("[", "]")
  end

  def to_bin(o) when is_tuple(o) do
    o
    |> Tuple.to_list()
    |> Enum.map(fn item -> to_bin(item) end)
    |> Enum.join(", ")
    |> wrap_str("{", "}")
  end

  def to_bin(o) when is_map(o) and not is_struct(o) do
    o
    |> Enum.map(fn {key, val} -> "#{map_key(key)}: #{to_bin(val)}" end)
    |> Enum.join(", ")
    |> wrap_str("%{", "}")
  end

  def to_bin(o) do
    case String.Chars.impl_for(o) do
      # base case - we don't know what this thing is so we're going YOLO with inspect
      nil ->
        if is_struct(o) do
          to_bin_struct(o)
        else
          do_inspect(o)
        end

      # Oh - someone has implemented the protocol!? Make any adjustments you want here
      type ->
        case type do
          String.Chars.Atom -> ":#{o}"
          String.Chars.BitString -> "\"#{o}\""
          _ -> "#{o}"
        end
    end
  end

  defp map_key(o) when is_atom(o), do: "#{o}"
  defp map_key(o), do: to_bin(o)

  defp wrap_str(inner, front, back), do: front <> inner <> back

  # fallback for when we get a structure without a String.Chars implementation
  defp to_bin_struct(o) do
    inner = to_bin(Map.from_struct(o)) |> String.slice(1..-1)
    struct_name = o.__struct__ |> Atom.to_string() |> String.split(".") |> List.last()
    "%#{struct_name}#{inner}"
  end

  defp do_inspect(o), do: inspect(o, @inspect_opts)
end
