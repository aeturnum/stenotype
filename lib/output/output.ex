defmodule Stenotype.Output do
  def output(line, level_atom) do
    Stenotype.Output.Logger.output(line, level_atom)
  end
end
