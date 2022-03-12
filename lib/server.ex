defmodule Stenotype.Service do
  use GenServer

  import Logger

  @name StenotypeLogService

  def token(), do: GenServer.call(@name, :token)

  def handle_call(info, _from, state) do
    error("#{@name}: unexpected call: #{inspect(info)}")
    {:reply, nil, state}
  end

  def handle_cast(info, state) do
    error("#{@name}: unexpected call: #{inspect(info)}")
    {:noreply, state}
  end

  def handle_continue(:load_logs, state) do
    # locs = Common.Log.locations()
    # IO.inspect(locs, label: "log locations")
    {:noreply, state}
  end

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)
  def init(_), do: {:ok, %{}, {:continue, :load_logs}}
end
