defmodule StenotypeTest do
  use ExUnit.Case
  use Stenotype
  doctest Stenotype

  import ExUnit.CaptureLog

  test "debug" do
    # ex: "\e[36m|D]03/11| 22:40:00.22] [test/stenotype_test.exs:10]\" test\"\n\e[0m"
    # do not move debug line
    log =
      capture_log(fn ->
        debug("test")
      end)

    [tag, _date, file, message] = String.split(log, "]")

    assert tag == "\e[36m|D"
    assert file == " [test/stenotype_test.exs:13"
    assert message == " test\n\e[0m"
  end
end
