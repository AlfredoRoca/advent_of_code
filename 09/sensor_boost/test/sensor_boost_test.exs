defmodule SensorBoostTest do
  use ExUnit.Case
  # doctest SensorBoost
  test "runs program 1202" do
    assert SensorBoost.solution_for_program_number(12, 2) == 4_330_636
  end
end
