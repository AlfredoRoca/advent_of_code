defmodule Planet do
  defstruct name: "", orbits: 0
end

defmodule OrbitMap do
  @moduledoc """
  The documentation for OrbitMap is in the README.md
  """

  @doc """
  Orbit map verifier

  ## Parameters:

  - the map information, can be String or %{file: "map_data_input.txt"}

  ## Examples

  iex> OrbitMap.calculate_map_checksum("COM)B")
  1

  """

  def calculate_map_checksum(%{file: input}) do
    input
    |> get_map_data_from_file()
    |> calculate_map_checksum()
  end

  def calculate_map_checksum(map_data) when is_binary(map_data) do
    create_planetary_system()

    map_data
    |> prepare_data()
    |> process_data()
    |> do_handle_result()
  end

  def get_map_data_from_file(input) do
    input
    |> File.read!()
  end

  def prepare_data(map) when is_binary(map) do
    map
    |> String.split("\n", trim: true)
  end

  def process_data(map) when is_list(map) do
    calculate_orbits(map, "COM")
  end

  def calculate_orbits(map, inner) do
    outers = search_outers_in_map(map, inner)

    outers
    |> Enum.map(fn outer ->
      inner_planet = get_planet_in_system(inner)
      _outer_planet = get_or_put_planet_in_system(outer)
      update_planet_in_system(outer, 1 + inner_planet.orbits)
      calculate_orbits(map, outer)
    end)
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

  def do_handle_result(_) do
    {_planets, total_orbits_checksum} =
      Enum.map_reduce(:ets.tab2list(:system), 0, fn {_name, planet, _pid}, chksum ->
        {planet, chksum + planet.orbits}
      end)

    total_orbits_checksum
  end

  def create_planetary_system() do
    :ets.new(:system, [:named_table, :set, :protected])
    put_planet_in_system("COM")
  end

  def get_or_put_planet_in_system(name) do
    if get_planet_in_system(name) == nil do
      put_planet_in_system(name)
    end

    get_planet_in_system(name)
  end

  def get_planet_in_system(name) do
    try do
      {_name, planet, _} = :ets.lookup(:system, name) |> List.first()
      planet
    rescue
      _e -> nil
    end
  end

  @doc """
  It inserts a new object Planet with the name

  ## Parameters:

  - name: string with the name of the new planet

  ## Example:

  iex> OrbitMap.create_planetary_system()
  iex> OrbitMap.put_planet_in_system("SUN")
  :true
  """
  @spec put_planet_in_system(String.t()) :: boolean()
  def put_planet_in_system(name) do
    :ets.insert(:system, {name, %Planet{name: name}, self()})
  end

  def update_planet_in_system(name, orbits) do
    :ets.insert(:system, {name, %Planet{name: name, orbits: orbits}, self()})
  end
end
