defmodule OrbitMap do
  @moduledoc """
  The documentation for OrbitMap is in the README.md
  """

  @doc """
  Takes profit from list operations to calculate the distance between nodes
  """
  def calculate_transfers(map, origin, destination) do
    map = prepare_data(map)
    to_origin = get_orbits(map, [], origin)
    to_destination = get_orbits(map, [], destination)
    Enum.count((to_origin -- to_destination) ++ (to_destination -- to_origin))
  end

  def get_map_data_from_file(input) do
    input
    |> File.read!()
  end

  @doc """
  Orbit map verifier by checksumming the total number ob orbit jumps between all the objects to the COM (Center Of Mass)

  ## Parameters:

  - the map passed in a string

  ## Examples

  iex> OrbitMap.calculate_map_checksum("COM)B")
  1
  """
  def calculate_map_checksum(map_data) when is_binary(map_data) do
    map = prepare_data(map_data)

    list_of_planets =
      map
      |> Enum.map(fn i -> String.split(i, ")") end)
      |> List.flatten()
      |> Enum.uniq()

    OrbitMap.explore_map(list_of_planets -- ["COM", "YOU", "SAN"], map, %{planet: "COM", level: 0})
    |> Enum.reduce(0, fn %{planet: _planet, level: level}, acc -> level + acc end)
  end

  @doc """
  Orbit map verifier by checksumming the total number ob orbit jumps between all the objects to the COM (Center Of Mass)

  ## Parameters:

  - the map passed in a file, use like this: %{file: "map_data_input.txt"}
  """
  def calculate_map_checksum(%{file: input}) do
    input
    |> get_map_data_from_file()
    |> calculate_map_checksum()
  end

  @doc """
  Returns the list of planets with their distance to COM

  ## Parameters:

  - the list of planets
  - the map info
  - the starting point
  """
  def explore_map(
        list_of_planets,
        map,
        %{planet: inner, level: level}
      ) do
    search_outers_in_map(map, inner)
    |> Enum.flat_map(fn planet ->
      [
        %{planet: planet, level: level + 1}
        | OrbitMap.explore_map(
            list_of_planets,
            map,
            %{planet: planet, level: level + 1}
          )
      ]
    end)
  end

  @doc """
  Takes a map represented in a string and returns a list of pairs inner-outer

  ## Parameters

  - map: string representing an orbit map

  ## Examples

  iex> OrbitMap.prepare_data("COM)B\nB)C\nC)D")
  ["COM)B", "B)C", "C)D"]
  """
  def prepare_data(map) when is_binary(map) do
    map
    |> String.split("\n", trim: true)
  end

  def get_orbits(_map, orbits, name) when name == "COM", do: orbits

  def get_orbits(map, orbits, name) do
    inner = OrbitMap.search_inner_in_map(map, name)
    orbits = [OrbitMap.search_inner_in_map(map, name) | orbits]

    case inner do
      "COM" -> orbits
      _ -> get_orbits(map, orbits, inner)
    end
  end

  @doc """
  Takes a prepared map and a node and returns its immediate inner

  ## Parameters

  - map: prepared string
  - name: name of the inspected node

  ## Examples

  iex> OrbitMap.search_inner_in_map(OrbitMap.prepare_data("COM)B\nB)C\nC)D"), "B")
  COM
  """
  def search_inner_in_map(map, name) do
    map
    |> Enum.filter(fn item -> Regex.run(~r/\)#{name}/, item) end)
    |> List.first()
    |> String.split(")")
    |> List.first()
  end

  def search_outers_in_map(map, name) do
    map
    |> Enum.filter(fn item -> Regex.run(~r/#{name}\)/, item) end)
    |> Enum.map(fn item ->
      item
      |> String.split(")")
      |> List.last()
    end)
  end
end
