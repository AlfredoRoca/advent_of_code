defmodule SensorBoost do
  @moduledoc """
  Documentation for SensorBoost.
  """

  @doc """
  """
  def run_boost_program do
    program = File.read!("puzzle_input.txt")
    external_inputs = [1]
    IntcodeComputer.run(program, external_inputs)
  end
end
