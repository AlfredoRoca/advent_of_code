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

  test "map 6" do
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

    scanner = MonitoringStation.run_scanner(map)
    assert Enum.at(scanner, 0).p == {11, 12}
    assert Enum.at(scanner, 1).p == {12, 1}
    assert Enum.at(scanner, 2).p == {12, 2}
    assert Enum.at(scanner, 9).p == {12, 8}
    assert Enum.at(scanner, 19).p == {16, 0}
    assert Enum.at(scanner, 49).p == {16, 9}
    assert Enum.at(scanner, 99).p == {10, 16}
    assert Enum.at(scanner, 198).p == {9, 6}
    assert Enum.at(scanner, 199).p == {8, 2}
    assert Enum.at(scanner, 200).p == {10, 9}

    # another way
    scanner = MonitoringStation.run_scanner(map)
    {element, scanner} = MonitoringStation.vaporize(scanner)
    assert element.p == {11, 12}
    {element, scanner} = MonitoringStation.vaporize(scanner)
    assert element.p == {12, 1}
    {element, _scanner} = MonitoringStation.vaporize(scanner)
    assert element.p == {12, 2}
  end

  @tag f: true
  test "find vaporized at order nth" do
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

    # assert MonitoringStation.find_nth_vaporized(map, 1).p == {11, 12}
    # assert MonitoringStation.find_nth_vaporized(map, 100).p == {10, 16}
    # assert MonitoringStation.find_nth_vaporized(map, 200).p == {8, 2}
    # assert MonitoringStation.find_nth_vaporized(map, 201).p == {10, 9}
    assert MonitoringStation.find_nth_vaporized(map, 299).p == {11, 1}
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
