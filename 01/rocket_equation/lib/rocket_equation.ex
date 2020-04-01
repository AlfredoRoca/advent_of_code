defmodule RocketEquation do
  def calculate_fuel(mass) when is_list(mass) do
    mass
    |> Enum.reduce(0, fn x, acc -> calculate_fuel(x) + acc end)
  end

  def calculate_fuel(mass) do
    fuel_for_the_mass = calculate_fuel_for_mass(mass)
    fuel_for_the_fuel = calculate_fuel_for_fuel(fuel_for_the_mass)
    fuel_for_the_mass + fuel_for_the_fuel
  end

  def calculate_fuel_for_mass(mass) when is_binary(mass) do
    mass
    |> String.to_integer()
    |> calculate_fuel_for_mass()
  end

  def calculate_fuel_for_mass(mass) when is_integer(mass) do
    operation = trunc(mass / 3.0 - 2.0)
    if operation >= 0, do: operation, else: 0
  end

  def calculate_fuel_for_fuel(fuel) do
    f4f = calculate_fuel_for_mass(fuel)
    if f4f > 0.0, do: f4f + calculate_fuel_for_fuel(f4f), else: 0
  end
end
