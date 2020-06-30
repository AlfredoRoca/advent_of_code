defmodule AmplificationCircuitTest do
  use ExUnit.Case, async: false
  # doctest AmplificationCircuit

  test "sample program 1" do
    program = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
    phase_sequence = [4, 3, 2, 1, 0]

    {_, exit_code} =
      Enum.map_reduce(phase_sequence, 0, fn x, exit_code ->
        {_result, _program, exit_code} = IntcodeComputer.run(program, [x, exit_code])
        {x, exit_code}
      end)

    expected_code = 43210
    assert exit_code == expected_code
  end

  test "sample program 2" do
    program = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
    phase_sequence = [0, 1, 2, 3, 4]

    {_, exit_code} =
      Enum.map_reduce(phase_sequence, 0, fn x, exit_code ->
        {_result, _program, exit_code} = IntcodeComputer.run(program, [x, exit_code])
        {x, exit_code}
      end)

    expected_code = 54321
    assert exit_code == expected_code
  end

  test "sample program 3" do
    program =
      "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"

    phase_sequence = [1, 0, 4, 3, 2]

    {_, exit_code} =
      Enum.map_reduce(phase_sequence, 0, fn x, exit_code ->
        {_result, _program, exit_code} = IntcodeComputer.run(program, [x, exit_code])
        {x, exit_code}
      end)

    expected_code = 65210
    assert exit_code == expected_code
  end

  @tag final: true
  test "input program" do
    program = File.read!("puzzle_input.txt")

    exit_code =
      Enum.map(Lista.permutations([0, 1, 2, 3, 4]), fn phase_sequence ->
        {_, exit_code} =
          Enum.map_reduce(phase_sequence, 0, fn x, exit_code ->
            {_result, _program, exit_code} = IntcodeComputer.run(program, [x, exit_code])
            {x, exit_code}
          end)

        exit_code
      end)
      |> Enum.max()

    expected_code = 116_680

    assert exit_code == expected_code
  end
end

defmodule Lista do
  def permutations([]), do: [[]]

  def permutations(list) do
    for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
  end
end
