Benchee.run(
  %{
    "stretches" => fn ->
      paths =
        File.read!("paths.txt")
        |> String.split("\n", trim: true)

      CrossedWires.nearest_cross(paths)
    end,
    "points" => fn ->
      paths =
        File.read!("paths.txt")
        |> String.split("\n", trim: true)

      CrossedWiresLowMemEff.min_combined_steps(paths)
    end
  },
  warmup: 20,
  formatters: [Benchee.Formatters.Console],
  print: [
    benchmarking: true,
    configuration: true,
    fast_warning: true
  ],
  memory_time: 20
)
