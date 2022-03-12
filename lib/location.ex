defmodule Stenotype.Location do
  @path_secs 2

  defstruct file: "", line: 0, module: :none, function_atom: :none, arity: 0

  @type t :: %__MODULE__{
          file: binary(),
          line: integer(),
          module: atom(),
          function_atom: atom(),
          arity: integer()
        }

  def create(%{file: f, line: l, module: m, function: {atom, arity}}) do
    %__MODULE__{
      file: f,
      line: l,
      module: m,
      function_atom: atom,
      arity: arity
    }
  end

  def create({mod, atom_name, arity, [file: path, line: line]}) do
    %__MODULE__{
      file: path,
      line: line,
      module: mod,
      function_atom: atom_name,
      arity: arity
    }
  end

  def log_string(m = %__MODULE__{}) do
    file = String.split(m.file, "/") |> Enum.take(-1 * @path_secs) |> Enum.join("/")
    "[#{file}:#{line_str(m)}]"
  end

  def trace_string(m = %__MODULE__{}) do
    "#{line_str(m, 7)}| #{mod_str(m)}.#{m.function_atom}/#{m.arity}"
  end

  def locations() do
    handle = get_db_handle()
    CubDB.get(handle, :locations, %{})
  end

  def register_log_location(location = %__MODULE__{}, atom) do
    handle = get_db_handle()
    old = CubDB.get(handle, :locations, %{})
    vew_val = update_module_map(old, location, atom)
    CubDB.put(handle, :locations, vew_val)
    location
  end

  def register_log_location(location, atom) do
    create(location)
    |> register_log_location(atom)
  end

  defp line_str(%{line: line}, width \\ 0) do
    String.pad_leading("#{line}", width, " ")
  end

  defp mod_str(%{module: mod}) do
    case mod |> Atom.to_string() |> String.split(".") do
      ["Elixir" | rest] -> rest
      other -> [":erlang" | other]
    end
    |> Enum.join(".")
  end

  defp get_db_handle() do
    if :ets.whereis(:log_locations) == :undefined do
      # need to lock here to prevent deadlock
      :global.set_lock({__MODULE__, self()})
      :ets.new(:log_locations, [:set, :protected, :named_table])
      {:ok, db} = CubDB.start_link("priv/cubdb/logs")
      :ets.insert(:log_locations, {:db, db})
      :global.del_lock({__MODULE__, self()})
    end

    case get_from_ets() do
      {:ok, db} ->
        db

      :error ->
        :global.set_lock({__MODULE__, self()})
        {:ok, db} = get_from_ets()
        :global.del_lock({__MODULE__, self()})
        db
    end
  end

  defp get_from_ets() do
    case :ets.lookup(:log_locations, :db) do
      [{_, db}] ->
        {:ok, db}

      [] ->
        :error
    end
  end

  defp update_module_map(locs, location, atom) do
    up_mod =
      Map.get(locs, location.module, %{})
      |> update_function_map(location, atom)

    Map.put(locs, location.module, up_mod)
  end

  defp update_function_map(locs, location, atom) do
    up_mod =
      Map.get(locs, location.function_atom, %{})
      |> update_line_map(location, atom)

    Map.put(locs, location.function_atom, up_mod)
  end

  defp update_line_map(locs, location, atom) do
    Map.put(locs, location.line, {location, atom})
  end
end
