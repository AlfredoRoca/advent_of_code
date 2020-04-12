defmodule SecureContainer do
  import Integer

  def how_many_pw(range) do
    range
    |> get_pws()
    |> Enum.count()
  end

  def get_pws(range) do
    range
    |> Enum.filter(fn x ->
      meets_criteria?(x)
    end)
  end

  def meets_criteria?(x) do
    its_a_6_digit_number?(x) && digits_never_decrease?(x) && contains_adjacent_doubles(x) &&
      at_least_one_adjacent_pair(x)
  end

  def its_a_6_digit_number?(x) do
    length =
      x
      |> Integer.to_charlist()
      |> length()

    length == 6
  end

  def digits_never_decrease?(x) do
    ordered_digits =
      x
      |> Integer.to_string()
      |> String.split("", trim: true)
      |> Enum.sort()
      |> Enum.join("")
      |> String.to_integer()

    ordered_digits == x
  end

  def contains_adjacent_doubles(x) do
    digits =
      x
      |> Integer.to_string()
      |> String.split("", trim: true)

    [digits | ["a"]]
    |> List.flatten()
    |> Enum.reduce_while("", fn new, last ->
      if new == last, do: {:halt, new}, else: {:cont, new}
    end) != "a"
  end

  def at_least_one_adjacent_pair(x) do
    digits =
      x
      |> Integer.to_string()
      |> String.split("", trim: true)

    {_, _, meets} =
      [digits | ["a"]]
      |> List.flatten()
      |> Enum.reduce_while({"", 0, false}, fn new, {last, counter, meets} ->
        if new == last do
          {:cont, {new, counter + 1, false}}
        else
          if counter == 1 do
            {:halt, {new, 0, true}}
          else
            {:cont, {new, 0, false}}
          end
        end
      end)

    meets
  end
end
