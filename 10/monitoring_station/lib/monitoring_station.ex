defmodule MonitoringStation do
  @moduledoc """
  Documentation for MonitoringStation.
  """

  def start(_start_type, _start_args) do
    # TO BE ABLE TO DEBUG RUNNING MIX TEST, UNCOMMENT NEXT LINE
    __MODULE__.best_location()
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def day10_part1 do
    File.read!("puzzle_input.txt")
    |> best_location()
  end

  def best_location do
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

    best_location(map)
  end

  def best_location(map) do
    space = parse_map_into_space(map)
    # |> IO.inspect(label: "space")

    # [
    #   [".", "#", ".", ".", "#"],
    #   [".", ".", ".", ".", "."],
    #   ["#", "#", "#", "#", "#"],
    #   [".", ".", ".", ".", "#"],
    #   [".", ".", ".", "#", "#"]
    # ]

    asteroids = get_asteroids_from_space(space)
    # |> IO.inspect(label: "asteroids")

    # [{1, 0}, {4, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 3}, {3, 4}, {4, 4}]

    find_alignements(asteroids)
    |> find_visible()
    |> find_best_location
    |> IO.inspect(label: "best location")
  end

  # parses the map into an array
  def parse_map_into_space(map) do
    map
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn s -> String.split(s, "", trim: true) end)
  end

  # convert to set of asteroids's coordinates
  def get_asteroids_from_space(space) do
    for y <- 0..(Enum.count(space) - 1) do
      for x <- 0..(Enum.count(Enum.at(space, 0)) - 1) do
        if Enum.at(Enum.at(space, y), x) == "#" do
          {x, y}
        end
      end
      |> Enum.reject(&is_nil(&1))
    end
    |> List.flatten()
  end

  def find_alignements(asteroids) do
    Enum.flat_map(asteroids, fn p ->
      aligned_asteroids(asteroids, p)
    end)
    |> Enum.uniq()
    |> Enum.group_by(&List.first/1)
    |> Map.to_list()
  end

  def find_visible(alignements) do
    Enum.map(alignements, fn {p, alignements_of_p} ->
      without_origin =
        Enum.map(alignements_of_p, fn line -> Enum.reject(line, fn x -> x == p end) end)

      # [[{4, 1}, {1, 0}], [{4, 1}, {3, 0}], [{4, 1}, {4, 0}, {4, 2}], [{4, 1}, {3, 2}]]
      #  without {4,1} -> [[{1, 0}], [{3, 0}], [{4, 0}, {4, 2}], [{3, 2}]]

      {p,
       Enum.map(without_origin, fn line ->
         if Enum.count(line) == 1 do
           line
         else
           q = List.first(line)

           same_side_groups =
             Enum.group_by(line, fn r -> are_in_the_same_side_as_origin?(p, q, r) end)
             #  p={4,2} ; q={4,0} ; line = [{4, 0}, {4, 1}, {4, 3}, {4, 4}, {4, 5}]
             # %{false: [{4, 3}, {4, 4}, {4, 5}], true: [{4, 0}, {4, 1}]}
             |> Map.merge(%{true: [], false: []}, fn _k, v1, v2 -> v1 ++ v2 end)

           [nearer(same_side_groups.false, p), nearer(same_side_groups.true, p)]
           |> Enum.reject(&is_nil/1)
         end
       end)}
    end)
  end

  def space_dimensions(space) do
    {Enum.count(List.first(space)), Enum.count(space)}
  end

  def aligned_asteroids(asteroids, origin = {x0, y0}) do
    Enum.map(asteroids -- [origin], fn _p = {x1, y1} ->
      {dx, dy} = {x1 - x0, y1 - y0}

      [origin | MonitoringStation.aligned_to_origin_with_slope(asteroids, origin, {dx, dy})]
    end)
  end

  def aligned_to_origin_with_slope(asteroids, origin = {x0, _y0}, {dx, _dy}) when dx == 0 do
    Enum.filter(asteroids -- [origin], fn _p = {x, _y} -> x == x0 end)
  end

  def aligned_to_origin_with_slope(asteroids, origin = {_x0, y0}, {_dx, dy}) when dy == 0 do
    Enum.filter(asteroids -- [origin], fn _p = {_x, y} -> y == y0 end)
  end

  def aligned_to_origin_with_slope(asteroids, origin = {x0, y0}, {dx, dy}) do
    Enum.filter(asteroids -- [origin], fn _p = {x, y} ->
      !(x == x0) and (y - y0) / (x - x0) == dy / dx
    end)
  end

  def find_best_location(array_of_visible) do
    {p, visible} =
      Enum.max_by(array_of_visible, fn {_p, visible} -> Enum.count(List.flatten(visible)) end)

    %{p => Enum.count(List.flatten(visible))}
  end

  def nearer([], _), do: nil

  def nearer(aligned, _origin = {x0, y0}) do
    Enum.min_by(aligned, fn {x, y} -> abs(x - x0) + abs(y - y0) end)
  end

  def are_in_the_same_side_as_origin?([origin, p1, p2]) do
    are_in_the_same_side_as_origin?(origin, p1, p2)
  end

  def are_in_the_same_side_as_origin?({x0, y0}, {x1, y1}, {x2, y2}) do
    # p1,p2,p0 are aligned
    (x1 - x0) * (x2 - x0) >= 0 and (y1 - y0) * (y2 - y0) >= 0
  end
end
