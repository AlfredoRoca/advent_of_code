defmodule OrbitMap do
  @infinite 999_999_999
  alias Zippy.ZForest, as: Z

  defmodule Planet do
    defstruct name: "", orbits: 0, inner: nil, outers: []
  end

  defmodule Vertex do
    defstruct name: "", distance: 999_999_999, previous: nil, neighbours: []
  end

  defmodule PathStep do
    defstruct name: "", distance: 0, previous: nil
  end

  @moduledoc """
  The documentation for OrbitMap is in the README.md
  """

  @doc """
  Applies Dijkstra algorithm to find the shortest path
  https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
  """
  def calculate_transfers(map, origin, destination) do
    graph = create_planetary_system()

    graph =
      map
      |> prepare_data()
      |> parse_map(graph)

    IO.inspect(Z.value(graph))
    graph
    # populate_vertex_set_q(graph, origin)
    # |> travers_vertex_set_q_until_destination(destination)

    # get_total_distance_to(destination)
  end

  @doc """
  travers the ets table :system and returns a list of Vertex with
  distance infinite except origin and no predecesors
  It's the preparation part of the Dijkstra's Algorithm
  3      create vertex set Q
  4
  5      for each vertex v in Graph:
  6          dist[v] ← INFINITY
  7          prev[v] ← UNDEFINED
  8          add v to Q
  10      dist[source] ← 0
  """
  def populate_vertex_set_q(graph, origin) do
    Enum.map(graph, fn {_, %Planet{inner: inner, name: name, orbits: _orbits, outers: outers}, _} ->
      distance = if name == origin, do: 0, else: @infinite

      %Vertex{
        name: name,
        distance: distance,
        previous: nil,
        neighbours: Enum.reject([inner | outers], &is_nil/1)
      }
    end)
  end

  @doc """
  # Dijkstra's Algorithm: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
  12      while Q is not empty:
  13          u ← vertex in Q with min dist[u]
  14
  15          remove u from Q
  16
  17          for each neighbor v of u:           // only v that are still in Q
  18              alt ← dist[u] + length(u, v)
  19              if alt < dist[v]:
  20                  dist[v] ← alt
  21                  prev[v] ← u
  22
  23      return dist[], prev[]
  """
  def travers_vertex_set_q_until_destination(vertex_set_q, destination) do
    # scan vertex_set_q until it's empty
    # 1st retrieves the one with the minimum distance

    unless vertex_set_q |> Enum.empty?() do
      u =
        vertex_set_q
        |> Enum.min_by(fn %Vertex{name: _, distance: distance, previous: _} -> distance end)

      vertex_set_q = Enum.reject(vertex_set_q, fn i -> i == u end)

      # finish if destination found
      if u.name != destination do
        # outers of u
        u.neighbours
        |> Enum.map(fn neigh_name ->
          v = Enum.find(vertex_set_q, fn i -> i.name == neigh_name end)

          # only necessary if v is still in Q
          if v do
            # length of edge = distance between vertex
            alt = u.distance + 1

            # to replace it with updated_v
            if alt < v.distance do
              vertex_set_q = Enum.reject(vertex_set_q, fn i -> i == v end)

              new_v = %Vertex{
                name: v.name,
                distance: alt,
                previous: v.previous,
                neighbours: v.neighbours
              }

              vertex_set_q = [new_v | vertex_set_q]

              put_step_in_path(v.name, alt, u.name)
              travers_vertex_set_q_until_destination(vertex_set_q, destination)
            end
          end
        end)
      end
    end
  end

  def get_total_distance_to(destination) do
    {_, %OrbitMap.PathStep{distance: distance, name: _, previous: _}, _} =
      :ets.lookup(:path, destination) |> List.first()

    # the algo has been applied considering origin and destination as objects,
    # but they are not. So we must substract 2
    distance - 2
  end

  def put_step_in_path(name, distance, previous) do
    :ets.insert(
      :path,
      {name, %PathStep{name: name, distance: distance, previous: previous}, self()}
    )
  end

  def parse_map(map, graph) do
    start = "YOU"

    graph =
      parse_inner(map, start, graph)
      |> List.first()
  end

  def parse_inner(map, inner, graph) do
    outers =
      map
      |> search_outers_in_map(inner)

    case outers do
      [] ->
        graph
        |> Z.up()

      _ ->
        graph = graph |> Z.down()

        graph =
          outers
          |> Enum.map(fn outer ->
            graph = graph |> Z.insert(outer)
            graph = parse_inner(map, outer, graph)
          end)
          |> List.flatten()
    end
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
  Orbit map verifier by checksumming the total number ob orbit jumps between all the objects to the COM (Center Of Mass)

  ## Parameters:

  - the map passed in a string

  ## Examples

  iex> OrbitMap.calculate_map_checksum("COM)B")
  1
  """
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

  def process_data(map) when is_list(map) do
    calculate_orbits(map, "COM")
  end

  def calculate_orbits(map, inner) do
    outers = search_outers_in_map(map, inner)

    outers
    |> Enum.map(fn outer ->
      inner_planet = get_planet_in_system(inner)
      _outer_planet = get_or_put_planet_in_system(outer)
      update_planet_in_system(outer, 1 + inner_planet.orbits, nil, nil)
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
    Z.root("COM")
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

  def update_planet_in_system(name, orbits, inner, outers) do
    :ets.insert(
      :system,
      {name, %Planet{name: name, orbits: orbits, inner: inner, outers: outers}, self()}
    )
  end
end
