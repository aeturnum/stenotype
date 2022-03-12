defmodule StenotypeTest do
  use ExUnit.Case
  use Stenotype
  doctest Stenotype

  import ExUnit.CaptureLog

  test "debug single line" do
    # ex: "|D]03/12|13:22:30.71[test/stenotype_test.exs:13] test"
    # do not move debug line
    log =
      capture_log(fn ->
        debug("test")
      end)

    [tag, date_and_file, message] = String.split(log, "]")

    assert tag == "\e[36m|D"
    assert message == " test\n\e[0m"
    [_date, file] = String.split(date_and_file, "[")
    assert file == "test/stenotype_test.exs:13"
  end

  test "debug multi line" do
    # ex:
    # |D]03/12|13:24:07.43|---------\
    # |D][test/stenotype_test.exs:33]|test
    # |D][test/stenotype_test.exs:33]|test2
    # |D][test/stenotype_test.exs:33]|test3
    # do not move debug line
    log =
      capture_log(fn ->
        debug(["test", "test2", "test3"])
      end)

    [line1, line2, line3, line4, end_format] = String.split(log, "\n")

    [tag, date] = String.split(line1, "]")
    assert tag == "\e[36m|D"
    # content changes but format is the same
    # mo/dd|hh:mm:ss.ms|---------\
    assert String.length(date) == 28

    [tag, file, message] = String.split(line2, "]")
    assert tag == "|D"
    assert file == "[test/stenotype_test.exs:33"
    assert message == "|test"

    [tag, file, message] = String.split(line3, "]")
    assert tag == "|D"
    assert file == "[test/stenotype_test.exs:33"
    assert message == "|test2"

    [tag, file, message] = String.split(line4, "]")
    assert tag == "|D"
    assert file == "[test/stenotype_test.exs:33"
    assert message == "|test3"

    assert end_format == "\e[0m"
  end
end
