defmodule MonitoringStationTest do
  use ExUnit.Case
  doctest MonitoringStation

  test "map 1" do
    map = """
      .#..#
      .....
      #####
      ....#
      ...##
    """

    assert MonitoringStation.best_location(map) == %{{3, 4} => 8}
  end

  test "map 2" do
    map = """
    ......#.#.
    #..#.#....
    ..#######.
    .#.#.###..
    .#..#.....
    ..#....#.#
    #..#....#.
    .##.#..###
    ##...#..#.
    .#....####
    """

    assert MonitoringStation.best_location(map) == %{{5, 8} => 33}
  end

  test "map 3" do
    map = """
    #.#...#.#.
    .###....#.
    .#....#...
    ##.#.#.#.#
    ....#.#.#.
    .##..###.#
    ..#...##..
    ..##....##
    ......#...
    .####.###.
    """

    assert MonitoringStation.best_location(map) == %{{1, 2} => 35}
  end

  test "map 4" do
    map = """
    .#..#..###
    ####.###.#
    ....###.#.
    ..###.##.#
    ##.##.#.#.
    ....###..#
    ..#.#..#.#
    #..#.#.###
    .##...##.#
    .....#.#..
    """

    assert MonitoringStation.best_location(map) == %{{6, 3} => 41}
  end

  test "map 5" do
    map = """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """

    assert MonitoringStation.best_location(map) == %{{11, 13} => 210}
  end

  test "are_in_the_same_side_as_origin?({x0, y0}, {x1, y1}, {x2, y2})" do
    assert MonitoringStation.are_in_the_same_side_as_origin?([{1, 0}, {2, 0}, {3, 0}]) == true
    assert MonitoringStation.are_in_the_same_side_as_origin?([{2, 0}, {1, 0}, {3, 0}]) == false
    assert MonitoringStation.are_in_the_same_side_as_origin?([{0, -4}, {0, 2}, {0, 5}]) == true
    assert MonitoringStation.are_in_the_same_side_as_origin?([{0, 4}, {0, -2}, {0, 5}]) == false
    assert MonitoringStation.are_in_the_same_side_as_origin?([{1, 0}, {3, 1}, {-2, 1}]) == false
    assert MonitoringStation.are_in_the_same_side_as_origin?([{1, 0}, {2, 1}, {3, 2}]) == true
    assert MonitoringStation.are_in_the_same_side_as_origin?([{-3, -6}, {2, 4}, {1, 2}]) == true
  end
end
