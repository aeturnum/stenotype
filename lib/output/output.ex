defmodule Stenotype.Output do
  def output(statement = %{level: level}) do
    Stenotype.Output.Logger.output(statement, level)
  end
end
