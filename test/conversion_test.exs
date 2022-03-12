defmodule StenotypeTest.Format.Conversion do
  use ExUnit.Case
  alias Stenotype.Format.Conversion

  alias StenotypeTest.Support.{
    TestStruct,
    TestStructWithChars
  }

  test "special case atoms" do
    assert Conversion.to_bin(nil) == "nil"
    assert Conversion.to_bin(true) == "true"
    assert Conversion.to_bin(false) == "false"
  end

  test "atom" do
    assert Conversion.to_bin(:test) == ":test"
  end

  test "string" do
    assert Conversion.to_bin("test") == ~s("test")
  end

  test "struct" do
    assert Conversion.to_bin(TestStruct.new()) == ~s(%TestStruct{bool: true, string: ""})
  end

  test "string.chars is used" do
    assert Conversion.to_bin(TestStructWithChars.new()) ==
             ~s(These can really have unexpected values)
  end

  test "tuple" do
    val = {"test", TestStruct.new(), nil}
    expected = ~s({"test", %TestStruct{bool: true, string: ""}, nil})
    assert Conversion.to_bin(val) == expected
  end

  test "list" do
    val = [false, TestStruct.new(), "test"]
    expected = ~s([false, %TestStruct{bool: true, string: ""}, "test"])
    assert Conversion.to_bin(val) == expected
  end

  test "map" do
    val = %{:str => "test", :struct => TestStruct.new(), "nil" => nil}
    expected = ~s(%{str: \"test\", struct: %TestStruct{bool: true, string: ""}, "nil": nil})
    assert Conversion.to_bin(val) == expected
  end
end
