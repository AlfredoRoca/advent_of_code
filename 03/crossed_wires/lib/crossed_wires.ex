defmodule CrossedWires do
  def nearest_cross([path1, path2]) do
    intersections([path1, path2])
    |> Enum.map(fn intersection ->
      distance_to_instersection(path1, intersection) +
        distance_to_instersection(path2, intersection)
    end)
    |> Enum.min()
  end

  def get_stretches(path) do
    # "R8,U5,L5,D3"
    {stretches, _endpoint} =
      path
      |> String.split(",", trim: true)
      |> Enum.map_reduce({0, 0}, fn <<direction::binary-size(1), length::binary>>, {x, y} ->
        length = String.to_integer(length)

        case direction do
          "R" -> {{x..(x + length), y}, {x + length, y}}
          "L" -> {{x..(x - length), y}, {x - length, y}}
          "U" -> {{x, y..(y + length)}, {x, y + length}}
          "D" -> {{x, y..(y - length)}, {x, y - length}}
        end
      end)

    stretches
  end

  def intersection({%Range{first: x1_1, last: x2_1}, y_1}, {x_2, %Range{first: y1_2, last: y2_2}}) do
    # horizontal crosses vertical
    if !Range.disjoint?(x1_1..x2_1, x_2..x_2) && !Range.disjoint?(y1_2..y2_2, y_1..y_1) do
      {x_2, y_1}
    end
  end

  def intersection({x_1, %Range{first: y1_1, last: y2_1}}, {%Range{first: x1_2, last: x2_2}, y_2}) do
    # vertical crosses horizontal
    if !Range.disjoint?(y1_1..y2_1, y_2..y_2) && !Range.disjoint?(x1_2..x2_2, x_1..x_1) do
      {x_1, y_2}
    end
  end

  def intersection({%Range{first: x1_1, last: x2_1}, y_1}, {%Range{first: x1_2, last: x2_2}, y_2}) do
    # horizontal overlaps horizontal
    if y_1 == y_2 && !Range.disjoint?(x1_1..x2_1, x1_2..x2_2) do
      range_of_x =
        Enum.max([Enum.min([x1_1, x2_1]), Enum.min([x1_2, x2_2])])..Enum.min([
          Enum.max([x1_1, x2_1]),
          Enum.max([x1_2, x2_2])
        ])

      {range_of_x, y_1} |> split_range_into_points()
    end
  end

  def intersection({x_1, %Range{first: y1_1, last: y2_1}}, {x_2, %Range{first: y1_2, last: y2_2}}) do
    # vertical overlaps vertical
    if x_1 == x_2 && !Range.disjoint?(y1_1..y2_1, y1_2..y2_2) do
      range_of_y =
        Enum.max([Enum.min([y1_1, y2_1]), Enum.min([y1_2, y2_2])])..Enum.min([
          Enum.max([y1_1, y2_1]),
          Enum.max([y1_2, y2_2])
        ])

      {x_1, range_of_y} |> split_range_into_points()
    end
  end

  def intersections([path1, path2]) do
    stretches1 = get_stretches(path1)
    stretches2 = get_stretches(path2)

    stretches1
    |> Enum.map(fn stretch1 ->
      stretches2
      |> Enum.map(fn stretch2 ->
        intersection(stretch1, stretch2)
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> List.delete({0, 0})
    |> List.delete(nil)
  end

  def split_range_into_points({%Range{first: x1, last: x2}, y}) do
    x1..x2
    |> Enum.map(fn x -> {x, y} end)
  end

  def split_range_into_points({x, %Range{first: y1, last: y2}}) do
    y1..y2
    |> Enum.map(fn y -> {x, y} end)
  end

  def distance_in_stretch({%Range{first: x1, last: x2}, y1}, {xi, y2}) do
    if Range.disjoint?(x1..x2, xi..xi) || y1 != y2 do
      {:continue, abs(x1 - x2)}
    else
      {:stop, abs(x1 - xi)}
    end
  end

  def distance_in_stretch({x1, %Range{first: y1, last: y2}}, {x2, yi}) do
    distance_in_stretch({y1..y2, x1}, {yi, x2})
  end

  def distance_to_instersection(path, intersection) do
    path
    |> get_stretches()
    |> Enum.reduce_while(0, fn str, distance ->
      {command, partial_dist} = distance_in_stretch(str, intersection)

      if command == :continue,
        do: {:cont, distance + partial_dist},
        else: {:halt, distance + partial_dist}
    end)
  end
end
