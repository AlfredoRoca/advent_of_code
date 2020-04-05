defmodule CrossedWiresTest do
  use ExUnit.Case

  test "the nearest for paths 1" do
    distance = 6
    paths = ["R8,U5,L5,D3", "U7,R6,D4,L4"]

    assert CrossedWires.nearest_cross(paths) == distance
  end

  test "the nearest for paths 2" do
    distance = 159
    paths = ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]

    assert CrossedWires.nearest_cross(paths) == distance
  end

  test "the nearest for paths 3" do
    distance = 135

    paths = [
      "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
      "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    ]

    assert CrossedWires.nearest_cross(paths) == distance
  end

  test "the nearest for paths in the file" do
    distance = 1626

    paths =
      File.read!("paths.txt")
      |> String.split("\n", trim: true)

    assert CrossedWires.nearest_cross(paths) == distance
  end
end
