defmodule Stenotype.Format.Conversion do
  # inspect options
  @inspect_opts [
    printable_limit: 20,
    limit: 5
  ]
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
