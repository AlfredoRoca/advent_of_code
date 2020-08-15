defmodule ProgramTest do
  use ExUnit.Case

  test "runs program 1" do
    program = "1,0,0,0,99"
    expectation = "2,0,0,0,99"

    new_program =
      Program.new(program)
      |> Program.run()

    assert Memory.dump_as_string(new_program.memory) == expectation
  end

  test "runs program 2" do
    program = "2,3,0,3,99"
    expectation = "2,3,0,6,99"

    new_program =
      Program.new(program)
      |> Program.run()

    assert Memory.dump_as_string(new_program.memory) == expectation
  end

  test "runs program 3" do
    program = "2,4,4,5,99,0"
    expectation = "2,4,4,5,99,9801"

    new_program =
      Program.new(program)
      |> Program.run()

    assert Memory.dump_as_string(new_program.memory) == expectation
  end

  test "runs program 4" do
    program = "1,1,1,4,99,5,6,0,99"
    expectation = "30,1,1,4,2,5,6,0,99"

    new_program =
      Program.new(program)
      |> Program.run()

    assert Memory.dump_as_string(new_program.memory) == expectation
  end

  test "runs program 5" do
    program = "1,9,10,3,2,3,11,0,99,30,40,50"
    expectation = "3500,9,10,70,2,3,11,0,99,30,40,50"

    new_program =
      Program.new(program)
      |> Program.run()

    assert Memory.dump_as_string(new_program.memory) == expectation
  end

  test "runs program 6" do
    program = "program_for_testing_the_computer.txt"
    expectation = "program_for_testing_the_computer - solution.txt"

    new_program =
      Program.new(file: program)
      |> Program.run()

    assert new_program.memory == Program.new(file: expectation).memory
  end

  test "diagnostic program" do
    program = "TEST_diagnostic_program.txt"
    expectation = 9_219_874
    external_inputs = [1]

    new_program =
      Program.new(file: program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expectation
  end

  test "sample program with negative integers" do
    program = "1101,100,-1,4,0"
    expectation = "1101,100,-1,4,99"

    new_program =
      Program.new(program)
      |> Program.run()

    assert new_program.memory == Program.new(expectation).memory
  end

  test "program with console input" do
    program = "3,2,0,99"
    external_inputs = [50]
    expectation = "3,2,50,99"

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert new_program.memory == Program.new(expectation).memory
  end

  test "program auto halting" do
    program = "1002,4,3,4,33"
    expectation = "1002,4,3,4,99"

    new_program =
      Program.new(program)
      |> Program.run()

    assert new_program.memory == Program.new(expectation).memory
  end

  test "diagnostic program for the ship's thermal radiator controller - System ID 5" do
    program = "TEST_diagnostic_program.txt"
    external_inputs = [5]
    expectation = 5_893_654

    new_program =
      Program.new(file: program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expectation
  end

  test "program with console output (inmediate mode)" do
    program = "3,0,104,42,99"
    expected_program = "50,0,104,42,99"
    external_inputs = [50]
    expected_output = 42

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
    assert new_program.memory == Program.new(expected_program).memory
  end

  test "program with console output (position mode)" do
    program = "3,0,4,0,99"
    expected_program = "50,0,4,0,99"
    external_inputs = [50]
    expected_output = 50

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
    assert new_program.memory == Program.new(expected_program).memory
  end

  test "sample program 4 - combined above 8" do
    # This example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.

    program =
      "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

    external_inputs = [42]
    expected_output = 1001

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program 4 - combined equals 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.

    program =
      "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

    external_inputs = [8]
    expected_output = 1000

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program 4 - combined below 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.

    program =
      "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

    external_inputs = [2]
    expected_output = 999

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 5 (immediate mode) - no jump if input 0 " do
    program = "3,3,1105,-1,9,1101,23,6,12,4,12,99,1"
    external_inputs = [0]
    expected_output = 29

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 5 (immediate mode) - jump if input non 0" do
    program = "3,3,1105,-1,9,1101,23,6,12,4,12,99,1"
    external_inputs = [42]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 6 (position mode) - no jump if input non 0 " do
    program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
    external_inputs = [0]
    expected_output = 0

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 6 (position mode) - jump if input 0" do
    program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
    external_inputs = [42]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 6 (immediate mode) - jump if input 0" do
    program = "3,3,1006,-1,8,104,66,10,104,88,99,-1,0,1,9"
    external_inputs = [0]
    expected_output = 88

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 6 (immediate mode) - no jump if input non 0" do
    program = "3,3,1106,-1,15,1101,1,2,10,104,-1,99,-1,0,1,9"
    external_inputs = [42]
    expected_output = 3

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 8 (position mode) - equal -> true" do
    program = "3,9,8,9,10,9,4,9,99,-1,8"
    external_inputs = [8]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 8 (immediate mode) - equal -> true" do
    program = "3,3,1108,-1,8,9,4,9,99"
    external_inputs = [8]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 8 (mixed mode) - equal -> true" do
    program = "3,10,1008,10,8,9,4,9,99,-1,8"
    external_inputs = [8]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 8 (position mode) - equal -> false" do
    program = "3,9,8,9,10,9,4,9,99,-1,8"
    external_inputs = [3]
    expected_output = 0

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program opcode 8 (immediate mode) - equal -> false" do
    program = "3,3,1108,-1,8,9,4,9,99"
    external_inputs = [3]
    expected_output = 0

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  @tag f: true
  test "test opcode 21108" do
    program = "21108,1,1,50,4,42,99"
    relative_base = -8
    external_inputs = []
    expectation = [1]

    outputs =
      Program.new(program)
      |> Program.run(external_inputs, relative_base)
      |> Program.print_outputs()

    assert outputs == expectation
  end

  test "test passing relative_base" do
    program = "1,0,0,0,99"
    relative_base = 10
    expectation = 10

    new_program =
      Program.new(program)
      |> Program.run([], relative_base)

    assert new_program.relative_base == expectation
  end

  test "test opcode 203" do
    program = "203,16,4,10,99"
    relative_base = -6
    external_inputs = [8]
    expectation = [8]

    outputs =
      Program.new(program)
      |> Program.run(external_inputs, relative_base)
      |> Program.print_outputs()

    assert outputs == expectation
  end

  test "test opcode 21101" do
    program = "21101,1,2,50,4,42,99"
    relative_base = -8
    external_inputs = []
    expectation = [3]

    outputs =
      Program.new(program)
      |> Program.run(external_inputs, relative_base)
      |> Program.print_outputs()

    assert outputs == expectation
  end

  test "Replicant" do
    program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    expectation = Memory.dump_as_list(Program.new(program).memory)

    new_program =
      Program.new(program)
      |> Program.run()

    assert Program.print_outputs(new_program) == expectation
  end

  test "can handle large numbers - 2" do
    program = "104,1125899906842624,99"
    expected_output = 1_125_899_906_842_624

    new_program =
      Program.new(program)
      |> Program.run()

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "can handle large numbers - 3" do
    program = "1102,34915192,34915192,7,4,7,99,0"
    expected_output = 1_219_070_632_396_864

    new_program =
      Program.new(program)
      |> Program.run()

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "relative base offset - 2" do
    program = "109,1,204,-1,99"
    expectation = 109

    new_program =
      Program.new(program)
      |> Program.run()

    assert List.last(Program.print_outputs(new_program)) == expectation
  end

  test "relative base offset - in relative mode" do
    program = "209,3,99,1,2,3,4,5,15"
    relative_base = 5
    expectation = 20

    new_program =
      Program.new(program)
      |> Program.run([], relative_base)

    assert new_program.relative_base == expectation
  end

  test "sample program 2 (position mode) - less than -> true" do
    program = "3,9,7,9,10,9,4,9,99,-1,8"
    external_inputs = [3]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program 2 (position mode) - less than -> false" do
    program = "3,9,7,9,10,9,4,9,99,-1,8"
    external_inputs = [42]
    expected_output = 0

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program 2 (immediate mode) - less than -> true" do
    program = "3,3,1107,-1,8,3,4,3,99"
    external_inputs = [3]
    expected_output = 1

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end

  test "sample program 2 (immediate mode) - less than -> false" do
    program = "3,3,1107,-1,8,3,4,3,99"
    external_inputs = [42]
    expected_output = 0

    new_program =
      Program.new(program)
      |> Program.run(external_inputs)

    assert List.last(Program.print_outputs(new_program)) == expected_output
  end
end
