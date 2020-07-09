defmodule AmplificationCircuitTest do
  use ExUnit.Case, async: false
  # doctest AmplificationCircuit

  #
  #
  # tests part 2
  #
  #
  test "sample program 1 feedback mode" do
    program =
      "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"

    phase_sequence = [9, 8, 7, 6, 5]
    expected_code = 139_629_729

    exit_code = AmplificationCircuit.get_amplifiers_output(phase_sequence, program)

    assert exit_code == expected_code
  end

  @tag :f
  test "sample program 2 feedback mode" do
    program =
      "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"

    phase_sequence = [9, 7, 8, 5, 6]
    expected_code = 18216

    exit_code = AmplificationCircuit.get_amplifiers_output(phase_sequence, program)

    assert exit_code == expected_code
  end

  @tag final: true
  @tag timeout: :infinity
  test "input program feedback mode" do
    program = File.read!("puzzle_input.txt")
    phase_sequence = [5, 6, 7, 8, 9]

    exit_code =
      AmplificationCircuit.find_highest_amplifiers_output_signal(phase_sequence, program)

    expected_code = 116_680

    assert exit_code == expected_code
  end

  #
  #
  # tests part 1
  #
  #
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
