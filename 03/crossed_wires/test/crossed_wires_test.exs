defmodule CrossedWiresTest do
  use ExUnit.Case

  test "stretches for paths 1" do
    [path1, path2] = ["R8,U5,L5,D3", "U7,R6,D4,L4"]
    stretches1 = [{0..8, 0}, {8, 0..5}, {8..3, 5}, {3, 5..2}]
    stretches2 = [{0, 0..7}, {0..6, 7}, {6, 7..3}, {6..2, 3}]

    assert CrossedWires.get_stretches(path1) == stretches1
    assert CrossedWires.get_stretches(path2) == stretches2
  end

  test "cross of stretches horizontal with vertical" do
    assert CrossedWires.intersection({0..8, 5}, {3, 0..7}) == {3, 5}
  end

  test "cross of stretches vertical with horizontal" do
    assert CrossedWires.intersection({8, 5..-16}, {-3..14, -6}) == {8, -6}
  end

  test "overlapping of stretches horizontal with horizontal" do
    assert CrossedWires.intersection({0..10, 4}, {0..-10, 4}) == [{0, 4}]
  end

  test "overlapping of stretches vertical with vertical" do
    assert CrossedWires.intersection({4, 0..10}, {4, 0..-10}) == [{4, 0}]
  end

  test "split an horizontal range into a list of points" do
    assert CrossedWires.split_range_into_points({3..6, 5}) == [{3, 5}, {4, 5}, {5, 5}, {6, 5}]
  end

  test "split a vertical range into a list of points" do
    assert CrossedWires.split_range_into_points({2, 3..5}) == [{2, 3}, {2, 4}, {2, 5}]
  end

  test "intersections of paths 1" do
    paths = ["R8,U5,L5,D3", "U7,R6,D4,L4"]

    assert CrossedWires.intersections(paths) == [{6, 5}, {3, 3}]
  end

  test "intersections for paths c1" do
    paths = ["R1050,D250,L250,U1050", "U500,R1051"]
    intersections = [{800, 500}]
    # distance = 2300 + 1300
    assert CrossedWires.intersections(paths) == intersections
  end

  test "intersections for paths 2" do
    paths = ["R10,D5,L3,U20", "U1,R20"]
    intersections = [{7, 1}]
    #   distance = 8 + 24
    assert CrossedWires.intersections(paths) == intersections
  end

  test "distance in strech going right" do
    stretch = {4..10, 0}
    intersection = {6, 0}
    distance = 2

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:stop, distance}
  end

  test "distance in strech going right other axis" do
    stretch = {0, 4..10}
    intersection = {0, 6}
    distance = 2

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:stop, distance}
  end

  test "distance in strech going left" do
    stretch = {10..4, 0}
    intersection = {6, 0}
    distance = 4

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:stop, distance}
  end

  test "distance in strech going right negative" do
    stretch = {-10..4, 0}
    intersection = {-1, 0}
    distance = 9

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:stop, distance}
  end

  test "distance in strech going left negative" do
    stretch = {-1..-9, 0}
    intersection = {-8, 0}
    distance = 7

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:stop, distance}
  end

  test "distance in strech outside the stretch" do
    stretch = {4..10, 0}
    intersection = {6, 5}
    distance = 6

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:continue, distance}
  end

  test "distance in strech outside the stretch other axis" do
    stretch = {0, 4..12}
    intersection = {6, 5}
    distance = 8

    assert CrossedWires.distance_in_stretch(stretch, intersection) == {:continue, distance}
  end

  test "distance to intersection in path 1" do
    path = "R8,U5,L5,D3"
    intersection = {6, 5}
    distance = 15

    assert CrossedWires.distance_to_instersection(path, intersection) == distance
  end

  test "distance to intersection in path 2" do
    path = "U7,R6,D4,L4"
    intersection = {6, 5}
    distance = 15

    assert CrossedWires.distance_to_instersection(path, intersection) == distance
  end

  test "the shortest path for paths 1" do
    paths = ["R8,U5,L5,D3", "U7,R6,D4,L4"]
    distance = 30

    assert CrossedWires.nearest_cross(paths) == distance
  end

  test "the shortest path for paths 2" do
    paths = ["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"]
    distance = 610

    assert CrossedWires.nearest_cross(paths) == distance
  end

  test "the shortest path for paths 3" do
    paths = [
      "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
      "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    ]

    distance = 410

    assert CrossedWires.nearest_cross(paths) == distance
  end

  test "the shortest path for paths in the file" do
    paths =
      File.read!("paths.txt")
      |> String.split("\n", trim: true)

    distance = 27330

    assert CrossedWires.nearest_cross(paths) == distance
  end
end
