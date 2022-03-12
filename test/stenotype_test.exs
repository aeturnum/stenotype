defmodule StenotypeTest do
  use ExUnit.Case
  use Stenotype
  doctest Stenotype

  import ExUnit.CaptureLog

  test "debug single line" do
    # ex: "|D][test/stenotype_test.exs:13]<03/12|12:14:33.67> test"
    # do not move debug line
    log =
      capture_log(fn ->
        debug("test")
      end)

    [tag, file, date_and_message] = String.split(log, "]")

    assert tag == "\e[36m|D"
    assert file == "[test/stenotype_test.exs:13"
    [_date, message] = String.split(date_and_message, ">")
    assert message == " test\n\e[0m"
  end

  test "debug multi line" do
    # ex:
    # |D][test/stenotype_test.exs:32]\<03/12|12:14:33.66>
    # |D][test/stenotype_test.exs:32] |test
    # |D][test/stenotype_test.exs:32] |test2
    # |D][test/stenotype_test.exs:32] |test3
    # do not move debug line
    log =
      capture_log(fn ->
        debug(["test", "test2", "test3"])
      end)

    [line1, line2, line3, line4, end_format] = String.split(log, "\n")

    [tag, file, date] = String.split(line1, "]")
    assert tag == "\e[36m|D"
    assert file == "[test/stenotype_test.exs:33"
    # content changes but format is the same
    assert String.length(date) == 21

    [tag, file, message] = String.split(line2, "]")
    assert tag == "|D"
    assert file == "[test/stenotype_test.exs:33"
    assert message == " |test"

    [tag, file, message] = String.split(line3, "]")
    assert tag == "|D"
    assert file == "[test/stenotype_test.exs:33"
    assert message == " |test2"

    [tag, file, message] = String.split(line4, "]")
    assert tag == "|D"
    assert file == "[test/stenotype_test.exs:33"
    assert message == " |test3"

    assert end_format == "\e[0m"
  end
end
