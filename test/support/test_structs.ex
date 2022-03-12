defmodule StenotypeTest.Support.TestStruct do
  defstruct string: "", bool: true

  def new() do
    %__MODULE__{}
  end
end

defmodule StenotypeTest.Support.TestStructWithChars do
  defstruct string: "", bool: true

  def new() do
    %__MODULE__{}
  end
end

defimpl String.Chars, for: StenotypeTest.Support.TestStructWithChars do
  def to_string(_module) do
    "These can really have unexpected values"
  end
end
