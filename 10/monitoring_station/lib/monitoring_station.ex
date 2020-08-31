defmodule MonitoringStation do
  @moduledoc """
  Documentation for MonitoringStation.
  """
  @infinite :math.pow(2, 100)

  def start(_start_type, _start_args) do
    # __MODULE__.day10_part2()

    map1 = """
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

    map2 = """
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

    map = map2

    __MODULE__.day10_part2(map, 299)
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def day10_part1 do
    File.read!("puzzle_input.txt")
    |> best_location()
  end

  def day10_part2 do
    day10_part2(File.read!("puzzle_input.txt"))
  end

  def day10_part2(map, nth \\ 1) do
    processed_map = process_map(map)

    best_asteroid =
      processed_map
      |> Enum.map(&get_scan/1)
      |> guess_best_place()
      |> IO.inspect(label: "best asteroid")

    visible_at_best_place(processed_map, best_asteroid)
    |> get_nth_vaporized(best_asteroid, nth)
    |> IO.inspect(label: "solution vaporized nth = #{nth}")
  end

  def process_map(map) do
    map
    |> parse_map_into_space()
    |> get_asteroids_from_space()
    |> find_alignements()
    |> order_by_distance()
  end

  def order_by_distance(alignements) do
    # receives alignements of all points
    # returns a list of tuples {asteroid, list of alignements}
    # {{3, 3},
    #  [
    #    [{5, 6}, {7, 9}, {13, 18}],
    #    [{1, 0}],
    #    [{2, 6}, {1, 9}],
    #    [{4, 0}],
    #    [{1, 6}], ...
    #  ]

    Enum.map(alignements, fn {p, alignements_of_p} ->
      {p,
       Enum.flat_map(alignements_of_p, fn line ->
         if Enum.count(line) == 1 do
           [line]
         else
           q = List.first(line)

           same_side_groups =
             Enum.group_by(line, fn r -> are_in_the_same_side_as_origin?(p, q, r) end)
             #  p={4,2} ; q={4,0} ; line = [{4, 0}, {4, 1}, {4, 3}, {4, 4}, {4, 5}]
             # %{false: [{4, 3}, {4, 4}, {4, 5}], true: [{4, 0}, {4, 1}]}
             #  this line is to ensure both sides are present
             |> Map.merge(%{true: [], false: []}, fn _k, v1, v2 -> v1 ++ v2 end)

           [
             Enum.sort_by(same_side_groups.false, &distance_to_origin(&1, p)),
             Enum.sort_by(same_side_groups.true, &distance_to_origin(&1, p))
           ]
           |> Enum.reject(&is_nil/1)
           |> Enum.reject(&Enum.empty?/1)
         end
       end)}
    end)
  end

  def get_scan({origin = {x0, _y0}, alignements}) do
    # returns the first round of the scanner, ie the nearer points in each alignement
    # the returned structure is a list of maps like %{p: {x,y}, tg: tg angle alignement}
    first_wave = Enum.map(alignements, &List.first/1)

    %{:g1 => g1, :g2 => g2, :g3 => g3, :g4 => g4} =
      Enum.reduce(first_wave, %{:g1 => [], :g2 => [], :g3 => [], :g4 => []}, fn p = {x, _y},
                                                                                %{
                                                                                  :g1 => g1,
                                                                                  :g2 => g2,
                                                                                  :g3 => g3,
                                                                                  :g4 => g4
                                                                                } ->
        tg_a = MonitoringStation.tg_a(origin, p)

        [g1, g2, g3, g4] =
          if tg_a > 0 do
            if x >= x0,
              do: [[%{:p => p, :tg => tg_a} | g1], g2, g3, g4],
              else: [g1, g2, [%{:p => p, :tg => tg_a} | g3], g4]
          else
            if x >= x0,
              do: [g1, [%{:p => p, :tg => tg_a} | g2], g3, g4],
              else: [g1, g2, g3, [%{:p => p, :tg => tg_a} | g4]]
          end
          |> Enum.map(fn g -> Enum.sort_by(g, & &1.tg) |> Enum.reverse() end)

        %{:g1 => g1, :g2 => g2, :g3 => g3, :g4 => g4}
      end)

    {origin, [[[g1 | g2] | g3] | g4] |> List.flatten()}
  end

  def guess_best_place(scans) do
    # receives a list of tuples formed by a tuple of a point and a list of list of map-points %{p: _, tg: _}
    # [
    #   {{8, 0},[%{p: {9, 0}, tg: 0.0},%{p: {18, 1}, tg: -0.1}]},
    #   {{15, 9},[%{p: {15, 8}, tg: 1.267e30},%{p: {16, 0}, tg: 9.0}, ...
    # ]
    {p, visible} = Enum.max_by(scans, fn {_p, visible} -> Enum.count(visible) end)

    %{p => Enum.count(visible)}
    |> Map.keys()
    |> List.first()
  end

  def visible_at_best_place(processed_map, best) do
    Enum.filter(processed_map, fn {p, _} -> p == best end)
    |> List.first()
  end

  def get_nth_vaporized(scanner, best_asteroid, nth) do
    {exit_code, response} = try_get_nth_vaporized(scanner, best_asteroid, nth)

    case exit_code do
      :ok -> response.p
      :error -> response
    end
  end

  def try_get_nth_vaporized(scanner, best_asteroid, nth) do
    scan = {_p, alignements} = get_scan(scanner)

    size = Enum.count(alignements)

    if alignements == [] do
      {:error, "Not found"}
    else
      if nth <= size do
        {:ok, Enum.at(alignements, nth - 1)}
      else
        remove_scan_from_scanner(scanner, scan)
        |> try_get_nth_vaporized(best_asteroid, nth - size)
      end
    end
  end

  def remove_scan_from_scanner(_scanner = {origin, points}, _scan = {_p, alignements}) do
    scan_points = Enum.map(alignements, &Map.get(&1, :p))

    # => [{5, 3}, {6, 0}, {6, 2}, {6, 3}, {7, 2}, {8, 0}, {7, 3}]
    remaining_points = Enum.reject(points, fn p -> Enum.find(scan_points, fn s -> s == p end) end)
    {origin, remaining_points}
  end

  def distance_to_origin(_p = {x, y}, _origin = {x0, y0}) do
    abs(x - x0) + abs(y - y0)
  end

  def run_scanner(map) when is_binary(map) do
    process_map(map)
    |> run_scanner
  end

  def run_scanner(all_visible) when is_list(all_visible) do
    best = guess_best_place(all_visible)
    visible = visible_at_best_place(all_visible, best)
    order_for_scan(visible)
  end

  def vaporize(scanner_map) do
    {_element, _scanner_map} = List.pop_at(scanner_map, 0)
  end

  def find_best_location(array_of_scans) do
    {p, visible} = Enum.max_by(array_of_scans, fn {_p, visible} -> Enum.count(visible) end)

    %{p => Enum.count(visible)}
  end

  def order_for_scan([{origin = {x0, _y0}, visible}]) do
    %{:g1 => g1, :g2 => g2, :g3 => g3, :g4 => g4} =
      Enum.reduce(visible, %{:g1 => [], :g2 => [], :g3 => [], :g4 => []}, fn p = {x, _y},
                                                                             %{
                                                                               :g1 => g1,
                                                                               :g2 => g2,
                                                                               :g3 => g3,
                                                                               :g4 => g4
                                                                             } ->
        tg_a = tg_a(origin, p)

        [g1, g2, g3, g4] =
          if tg_a > 0 do
            if x >= x0,
              do: [[%{:p => p, :tg => tg_a} | g1], g2, g3, g4],
              else: [g1, g2, [%{:p => p, :tg => tg_a} | g3], g4]
          else
            if x >= x0,
              do: [g1, [%{:p => p, :tg => tg_a} | g2], g3, g4],
              else: [g1, g2, g3, [%{:p => p, :tg => tg_a} | g4]]
          end
          |> Enum.map(fn g -> Enum.sort_by(g, & &1.tg) |> Enum.reverse() end)

        %{:g1 => g1, :g2 => g2, :g3 => g3, :g4 => g4}
      end)

    [[[g1 | g2] | g3] | g4]
    |> List.flatten()
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
    |> order_by_distance()
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
    # returns a list of tuples like {origin, list of alignements (alignement is a list of aligned asteroids)}
    Enum.flat_map(asteroids, fn p ->
      aligned_asteroids(asteroids, p)
    end)
    |> Enum.uniq()
    |> Enum.group_by(&List.first/1)
    |> Map.to_list()
    |> Enum.map(fn {p, alignements_of_p} ->
      {p, Enum.map(alignements_of_p, fn line -> Enum.reject(line, fn x -> x == p end) end)}
    end)
  end

  @spec space_dimensions([any]) :: {non_neg_integer, non_neg_integer}
  def space_dimensions(space) do
    {Enum.count(List.first(space)), Enum.count(space)}
  end

  def aligned_asteroids(asteroids, origin = {x0, y0}) do
    Enum.map(asteroids -- [origin], fn _p = {x1, y1} ->
      {dx, dy} = {x1 - x0, y1 - y0}
      [origin | aligned_to_origin_with_slope(asteroids, origin, {dx, dy})]
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

  def tg_a({x0, y0}, {x, y}) when x == x0 and y < y0, do: @infinite
  def tg_a({x0, y0}, {x, y}) when x == x0 and y > y0, do: -@infinite

  def tg_a({x0, y0}, {x, y}), do: (y0 - y) / (x - x0)
end
