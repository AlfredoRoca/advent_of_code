defmodule CrossedWiresLowMemEffTest do
  use ExUnit.Case

  test "combined_steps_to_intersection for paths 1" do
    [path1, path2] = ["R8,U5,L5,D3", "U7,R6,D4,L4"]
    route1 = CrossedWiresLowMemEff.get_points(path1, {0, 0})
    route2 = CrossedWiresLowMemEff.get_points(path2, {0, 0})
    intersection = {6, 5}
    distance = 30

    assert CrossedWiresLowMemEff.combined_steps_to_intersection(intersection, route1, route2) ==
             distance
  end

  test "combined_steps_to_intersection for paths c1" do
    [path1, path2] = ["R1050,D250,L250,U1050", "U500,R1051"]
    route1 = CrossedWiresLowMemEff.get_points(path1, {0, 0})
    route2 = CrossedWiresLowMemEff.get_points(path2, {0, 0})
    intersection = {800, 500}
    distance = 2300 + 1300

    assert CrossedWiresLowMemEff.combined_steps_to_intersection(intersection, route1, route2) ==
             distance
  end

  test "combined_steps_to_intersection for paths c2" do
    [path1, path2] = ["R10,D5,L3,U20", "U1,R20"]
    route1 = CrossedWiresLowMemEff.get_points(path1, {0, 0})
    route2 = CrossedWiresLowMemEff.get_points(path2, {0, 0})
    intersection = {7, 1}
    distance = 8 + 24

    assert CrossedWiresLowMemEff.combined_steps_to_intersection(intersection, route1, route2) ==
             distance
  end

  test "the nearest for paths 1" do
    distance = 6
    paths = ["R8,U5,L5,D3", "U7,R6,D4,L4"]

    assert CrossedWiresLowMemEff.nearest_cross(paths) == distance
  end

  test "get the points of paths 1" do
    path = "R8,U5,L5,D3"
    quantity = 21

    assert CrossedWiresLowMemEff.get_points(path, {0, 0}) |> Enum.count() == quantity
  end

  test "the shortest path for paths 1" do
    paths = ["R8,U5,L5,D3", "U7,R6,D4,L4"]
    min_combined_steps = 30

    assert CrossedWiresLowMemEff.min_combined_steps(paths) == min_combined_steps
  end

  test "the nearest for paths 2" do
    distance = 159
    paths = ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]

    assert CrossedWiresLowMemEff.nearest_cross(paths) == distance
  end

  test "the shortest path for paths 2" do
    paths = ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]
    min_combined_steps = 610

    assert CrossedWiresLowMemEff.min_combined_steps(paths) == min_combined_steps
  end

  test "the nearest for paths 3" do
    distance = 135

    paths = [
      "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
      "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    ]

    assert CrossedWiresLowMemEff.nearest_cross(paths) == distance
  end

  test "the shortest path for paths 3" do
    paths = [
      "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
      "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    ]

    min_combined_steps = 410

    assert CrossedWiresLowMemEff.min_combined_steps(paths) == min_combined_steps
  end

  test "the nearest for paths in the file" do
    distance = 1626

    paths =
      File.read!("paths.txt")
      |> String.split("\n", trim: true)

    assert CrossedWiresLowMemEff.nearest_cross(paths) == distance
  end

  test "the shortest path for paths in the file" do
    paths =
      File.read!("paths.txt")
      |> String.split("\n", trim: true)

    min_combined_steps = 27330

    assert CrossedWiresLowMemEff.min_combined_steps(paths) == min_combined_steps
  end
end
