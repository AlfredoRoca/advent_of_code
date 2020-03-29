defmodule RocketEquation do
  def calculate_fuel(mass) when is_binary(mass) do
    mass
    |> String.to_integer()
    |> calculate_fuel()
  end

  def calculate_fuel(mass) when is_integer(mass) do
    trunc(mass / 3 - 2)
  end

  def calculate_fuel(list) when is_list(list) do
    list
    |> Enum.reduce(0, fn x, acc -> calculate_fuel(String.to_integer(x)) + acc end)
  end
end
