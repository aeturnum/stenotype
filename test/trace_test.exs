defmodule StenotypeTest.Format.Trace do
  use ExUnit.Case
  alias Stenotype.Format

  test "base trace" do
    # do not move this line
    trace =
      Enum.join(
        [
          "     18| StenotypeTest.Format.Trace.test base trace/1",
          "    500| ExUnit.Runner.exec_test/1",
          "    166| :erlang.timer.tc/1",
          "    451| ExUnit.Runner.-spawn_test_monitor/4-fun-1-/4"
        ],
        "\n"
      )

    assert Format.format_stack_trace() == trace
  end
end
