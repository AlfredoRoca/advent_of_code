defmodule RocketEquationTest do
  use ExUnit.Case

  test "calculate fuel for example 1" do
    input = 12
    expected_value = 2

    assert RocketEquation.calculate_fuel(input) == expected_value
  end

  test "calculate fuel for example 2" do
    input = 14
    expected_value = 2

    assert RocketEquation.calculate_fuel(input) == expected_value
  end

  test "calculate fuel for example 3" do
    input = 1969
    expected_value = 966

    assert RocketEquation.calculate_fuel(input) == expected_value
  end

  test "calculate fuel for example 4" do
    input = 100_756
    expected_value = 50_346

    assert RocketEquation.calculate_fuel(input) == expected_value
  end

  test "calculate fuel for example in file (multiple modules)" do
    input =
      File.read!("input.txt")
      |> String.split("\n", trim: true)

    expected_value = 5_154_075

    assert RocketEquation.calculate_fuel(input) == expected_value
  end
end
