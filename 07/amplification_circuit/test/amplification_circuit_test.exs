defmodule AmplificationCircuitTest do
  use ExUnit.Case, async: false
  # doctest AmplificationCircuit

  test "sample program 1" do
    program = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
    phase_sequence = [4, 3, 2, 1, 0]
    expected_code = 43210

    exit_code = AmplificationCircuit.get_amplifiers_output(phase_sequence, program)

    assert exit_code == expected_code
  end

  test "sample program 2" do
    program = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
    phase_sequence = [0, 1, 2, 3, 4]
    expected_code = 54321

    exit_code = AmplificationCircuit.get_amplifiers_output(phase_sequence, program)

    assert exit_code == expected_code
  end

  test "sample program 3" do
    program =
      "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"

    phase_sequence = [1, 0, 4, 3, 2]
    expected_code = 65210

    exit_code = AmplificationCircuit.get_amplifiers_output(phase_sequence, program)

    assert exit_code == expected_code
  end

  @tag final: true
  test "input program" do
    program = File.read!("puzzle_input.txt")
    phase_settings = [0, 1, 2, 3, 4]
    expected_code = 116_680

    exit_code =
      AmplificationCircuit.find_highest_amplifiers_output_signal(phase_settings, program)

    assert exit_code == expected_code
  end

  test "Lista.permutation" do
    items = [0, 1, 2]
    permutations = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]

    assert AmplificationCircuit.Lista.permutations(items) == permutations
  end
end
