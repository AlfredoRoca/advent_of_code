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

  def find_highest_amplifiers_output_signal(phase_settings_list, program) do
    Enum.map(Lista.permutations(phase_settings_list), fn phase_sequence ->
      get_amplifiers_output(phase_sequence, program)
    end)
    |> Enum.max()
  end

  def get_amplifiers_output(phase_sequence, program) do
    {_, exit_code} =
      Enum.map_reduce(phase_sequence, 0, fn x, exit_code ->
        {_result, _program, exit_code} = IntcodeComputer.run(program, [x, exit_code])
        {x, exit_code}
      end)

    exit_code
  end
end
