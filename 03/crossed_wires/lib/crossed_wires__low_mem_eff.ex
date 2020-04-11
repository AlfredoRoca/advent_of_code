defmodule CrossedWiresLowMemEff do
  def nearest_cross([path1, path2]) do
    route1 = get_points(path1, {0, 0})

    route2 = get_points(path2, {0, 0})

    minimum_distance_of_crossing_points(route1, route2)
  end

  def minimum_distance_of_crossing_points(route1, route2) do
    crossing_points_in(all_points_without_starting_point(route1, route2))
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  def all_points_without_starting_point(route1, route2) do
    (Enum.uniq(route1) ++ Enum.uniq(route2))
    |> Enum.reject(fn point -> point == {0, 0} end)
  end

  def crossing_points_in(all_points) do
    all_points -- Enum.uniq(all_points)
  end

  def get_points(path, {x0, y0}) do
    {route, _endpoint} =
      path
      |> String.split(",", trim: true)
      |> Enum.map_reduce({x0, y0}, fn <<direction::binary-size(1), length::binary>>, {x, y} ->
        length = String.to_integer(length)
        {points, {delta_x, delta_y}} = get_coordinates(direction, length, x, y)
        {points, {x + delta_x, y + delta_y}}
      end)

    List.flatten(route)
    |> Enum.dedup()
    |> Enum.reject(fn point -> point == {x0, y0} end)
  end

  def get_coordinates(direction, length, x0, y0) when direction == "R" do
    {points, new_x0} = Enum.map_reduce(0..length, x0, fn _x, x0 -> {{x0, y0}, x0 + 1} end)
    {points, {new_x0 - x0 - 1, 0}}
  end

  def get_coordinates(direction, length, x0, y0) when direction == "L" do
    {points, new_x0} = Enum.map_reduce(0..length, x0, fn _x, x0 -> {{x0, y0}, x0 - 1} end)
    {points, {new_x0 - x0 + 1, 0}}
  end

  def get_coordinates(direction, length, x0, y0) when direction == "U" do
    {points, new_y0} = Enum.map_reduce(0..length, y0, fn _y, y0 -> {{x0, y0}, y0 + 1} end)
    {points, {0, new_y0 - y0 - 1}}
  end

  def get_coordinates(direction, length, x0, y0) when direction == "D" do
    {points, new_y0} = Enum.map_reduce(0..length, y0, fn _y, y0 -> {{x0, y0}, y0 - 1} end)
    {points, {0, new_y0 - y0 + 1}}
  end

  def min_combined_steps([path1, path2]) do
    route1 = get_points(path1, {0, 0})
    route2 = get_points(path2, {0, 0})

    all_points_without_starting_point(route1, route2)
    |> crossing_points_in()
    |> Enum.map(fn point -> combined_steps_to_intersection(point, route1, route2) end)
    |> Enum.min()
  end

  def combined_steps_to_intersection(intersection, route1, route2) do
    Enum.find_index(route1, fn point -> point == intersection end) + 1 +
      Enum.find_index(route2, fn point -> point == intersection end) + 1
  end
end
