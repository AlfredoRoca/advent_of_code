# CrossedWires

## CrossedWiresLowMemEff:

*Slow and memory consuming*

Intersections found by looking for coincidences in the list of all points

## CrossedWires:

*Fast and more memory effective*

Intersections found by looking for stretches interesections


## Benchmarking

```
# mix run lib/benchmark.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-9600K CPU @ 3.70GHz
Number of Available Cores: 6
Available memory: 32 GB
Elixir 1.9.0
Erlang 21.3.3

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 20 s
parallel: 1
inputs: none specified
Estimated total run time: 54 s

Benchmarking points...
Benchmarking stretches...

Name                ips        average  deviation         median         99th %
stretches         69.47       14.39 ms    ±12.19%       14.02 ms       23.34 ms
points             1.42      702.92 ms     ±8.67%      696.44 ms      791.96 ms

Comparison:
stretches         69.47
points             1.42 - 48.84x slower +688.53 ms

Memory usage statistics:

Name         Memory usage
stretches        15.63 MB
points          400.68 MB - 25.64x memory usage +385.05 MB

**All measurements for memory usage were the same**
```
