defmodule SensorBoost do
  use Application

  @moduledoc """
  Documentation for SensorBoost.
  """

  @doc """
  """

  def start(_start_type, _start_args) do
    # TO BE ABLE TO DEBUG RUNNING MIX TEST, UNCOMMENT NEXT LINE
    __MODULE__.try_program("21108,1,2,50,4,42,99", [], -8)
    # __MODULE__.try_file("TEST_diagnostic_program copy.txt", [5])
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def day9_part1 do
    Program.new(file: "puzzle_input.txt")
    |> Program.run([1])
  end

  def try_file(file, inputs) do
    Program.new(file: file)
    |> Program.run(inputs)
  end

  # SensorBoost.try_program("1,0,0,0,99")
  def try_program(program, inputs \\ [], relative_base \\ 0) do
    Program.new(program)
    |> Program.run(inputs, relative_base)
  end

  def solution_for_program_number(noun, verb) do
    instructions =
      File.read!("program_for_testing_the_computer.txt")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.slice(3..-1)

    p =
      Enum.join([1, noun, verb] ++ instructions, ",")
      |> Program.new()
      |> Program.run()

    Memory.read(p.memory, 0, Memory.mode_immediate(), 0)
  end
end
