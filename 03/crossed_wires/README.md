# CrossedWires

https://adventofcode.com/2019/day/3

--- Day 3: Crossed Wires ---
The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

...........
...........
...........
....+----+.
....|....|.
....|....|.
....|....|.
.........|.
.o-------+.
...........
Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........
These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

Here are a few more examples:

R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83 = distance 159
R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
U98,R91,D20,R16,D67,R40,U7,R15,U6,R7 = distance 135
What is the Manhattan distance from the central port to the closest intersection?


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
