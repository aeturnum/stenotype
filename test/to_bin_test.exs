defmodule StenotypeTest.Format.ToBin do
  use ExUnit.Case
  alias Stenotype.Format

  alias StenotypeTest.Support.{
    TestStruct,
    TestStructWithChars
  }

  test "special case atoms" do
    assert Format.to_bin(nil) == "nil"
    assert Format.to_bin(true) == "true"
    assert Format.to_bin(false) == "false"
  end

  test "atom" do
    assert Format.to_bin(:test) == ":test"
  end

  test "string" do
    assert Format.to_bin("test") == ~s("test")
  end

  test "struct" do
    assert Format.to_bin(TestStruct.new()) == ~s(%TestStruct{bool: true, string: ""})
  end

  test "string.chars is used" do
    assert Format.to_bin(TestStructWithChars.new()) == ~s(These can really have unexpected values)
  end

  test "tuple" do
    val = {"test", TestStruct.new(), nil}
    expected = ~s({"test", %TestStruct{bool: true, string: ""}, nil})
    assert Format.to_bin(val) == expected
  end

  test "list" do
    val = [false, TestStruct.new(), "test"]
    expected = ~s([false, %TestStruct{bool: true, string: ""}, "test"])
    assert Format.to_bin(val) == expected
  end

  test "map" do
    val = %{:str => "test", :struct => TestStruct.new(), "nil" => nil}
    expected = ~s(%{str: \"test\", struct: %TestStruct{bool: true, string: ""}, "nil": nil})
    assert Format.to_bin(val) == expected
  end
end
