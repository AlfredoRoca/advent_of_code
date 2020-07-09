defmodule AmplificationCircuit do
  @moduledoc """
  Documentation for AmplificationCircuit.
  """
  defmodule Lista do
    def permutations([]), do: [[]]

    def permutations(list) do
      for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
    end
  end

  def find_highest_amplifiers_output_signal(possible_phases, program) do
    Enum.map(Lista.permutations(possible_phases), fn phase_sequence ->
      get_amplifiers_output(phase_sequence, program)
    end)
    |> Enum.max()
  end

  def get_amplifiers_output(phase_sequence, program) do
    input = 0

    {_, output} =
      Enum.map_reduce(phase_sequence, input, fn phase_number, output ->
        output = execute_program_on_amplifier(program, phase_number, output)

        {phase_number, output}
        |> IO.inspect(label: "28")
      end)

    output
  end

  def execute_program_on_amplifier(program, phase_number, input) do
    {:halt, _program, output} = IntcodeComputer.run(program, [phase_number, input])
    output
  end
end
