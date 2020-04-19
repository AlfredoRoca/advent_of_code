defmodule OrbitMapTest do
  use ExUnit.Case
  doctest OrbitMap

  test "calculates orbits checksum for sample map 1" do
    map = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """

    assert OrbitMap.calculate_map_checksum(map) == 42
  end

  @tag t: true
  test "calculates orbits checksum for sample map 1 disordered" do
    map = """
    C)D
    J)K
    COM)B
    E)F
    B)C
    D)E
    G)H
    D)I
    E)J
    B)G
    K)L
    """

    assert OrbitMap.calculate_map_checksum(map) == 42
  end

  test "calculates orbits checksum for input map" do
    map_file = "map_data_input.txt"
    assert OrbitMap.calculate_map_checksum(%{file: map_file}) == 312_697
  end
end
