defmodule IntcodeComputerTest do
  use ExUnit.Case, async: false
  require Logger
  import Mock

  @tag f: true
  test "can handle large numbers - 3" do
    program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    expected_result = program

    {_result, new_program, _exit_code, _relative_base} = IntcodeComputer.run(program)
    assert new_program == expected_result
  end

  test "relative base offset - 2" do
    program = "109,1,204,-1,99"
    expected_result = 109

    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program)
    assert exit_code == expected_result
  end

  test "can handle large numbers - 1" do
    program = "104,1125899906842624,99"
    expected_result = 1_125_899_906_842_624

    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program)
    assert exit_code == expected_result
  end

  test "can handle large numbers - 2" do
    program = "1102,34915192,34915192,7,4,7,99,0"
    expected_result = 1_219_070_632_396_864

    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program)
    assert exit_code == expected_result
  end

  test "relative base offset - 1" do
    program = "109,19,99"
    relative_base = 2000
    expected_result = 2019

    {_result, _program, _exit_code, relative_base} =
      IntcodeComputer.run(program, nil, relative_base)

    assert relative_base == expected_result
  end

  test "sample program 1 (position mode) - equal -> true" do
    program = "3,9,8,9,10,9,4,9,99,-1,8"
    external_inputs = [8]
    expected_code = 1
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 1 (immediate mode) - equal -> true" do
    program = "3,3,1108,-1,8,3,4,3,99"
    external_inputs = [8]
    expected_code = 1
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 1 (position mode) - equal -> false" do
    program = "3,9,8,9,10,9,4,9,99,-1,8"
    external_inputs = [3]
    expected_code = 0
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 1 (immediate mode) - equal -> false" do
    program = "3,3,1108,-1,8,3,4,3,99"
    external_inputs = [3]
    expected_code = 0
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 2 (position mode) - less than -> true" do
    program = "3,9,7,9,10,9,4,9,99,-1,8"
    external_inputs = [3]
    expected_code = 1
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 2 (position mode) - less than -> false" do
    program = "3,9,7,9,10,9,4,9,99,-1,8"
    external_inputs = [42]
    expected_code = 0
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 2 (immediate mode) - less than -> true" do
    program = "3,3,1107,-1,8,3,4,3,99"
    external_inputs = [3]
    expected_code = 1
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "variant program 2 (immediate mode) - less than -> true" do
    program = "3,3,1107,-1,8,3,4,3,99"
    new_prog = "3,3,1107,1,8,3,4,3,99"
    external_inputs = [3]
    {_result, program, exit_code, _} = IntcodeComputer.run(program, external_inputs)
    assert program == new_prog
    assert exit_code == 1
  end

  test "sample program 2 (immediate mode) - less than -> false" do
    program = "3,3,1107,-1,8,3,4,3,99"
    external_inputs = [42]
    expected_code = 0
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 3 (position mode) - jump input 0 " do
    program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
    external_inputs = [0]
    expected_code = 0
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 3 (position mode) - jump input non 0" do
    program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
    external_inputs = [42]
    expected_code = 1
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 3 (immediate mode) - jump input 0 " do
    program = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
    external_inputs = [0]
    expected_code = 0
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 3 (immediate mode) - jump input non 0" do
    program = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
    external_inputs = [42]
    expected_code = 1
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 4 - combined below 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.

    program = """
    3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,
    21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
    """

    external_inputs = [2]

    expected_code = 999
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 4 - combined equals 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.

    program = """
    3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,
    21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
    """

    external_inputs = [8]

    expected_code = 1000
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "sample program 4 - combined above 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.

    program = """
    3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,
    21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
    """

    external_inputs = [42]

    expected_code = 1001
    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
  end

  test "program with console output (position mode)" do
    program = "3,0,4,0,99"
    output = "50,0,4,0,99"
    external_inputs = [50]

    {_result, program, _exit_code, _} = IntcodeComputer.run(program, external_inputs)

    assert program == output
  end

  test "program with console output (inmediate mode)" do
    program = "3,0,104,42,99"
    output = "50,0,104,42,99"
    external_inputs = [50]
    expected_code = 42

    {_result, program, exit_code, _} = IntcodeComputer.run(program, external_inputs)

    assert exit_code == expected_code
    assert program == output
  end

  test "diagnostic program for the ship's thermal radiator controller - System ID 5" do
    Logger.info(
      "Running TEST diagnostic program for the ship's thermal radiator controller - System ID 5"
    )

    program = File.read!("TEST_diagnostic_program.txt")
    external_inputs = [5]

    expected_code = 5_893_654

    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == expected_code
    Logger.info("Exit code ship's thermal radiator controller diagnostic program = #{exit_code}")
  end

  test "program auto halting" do
    program = "1002,4,3,4,33"
    output = "1002,4,3,4,99"
    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "program with console input" do
    program = "3,2,0,99"
    external_inputs = [50]

    output = "3,2,50,99"
    {_result, program, _exit_code, _} = IntcodeComputer.run(program, external_inputs)
    assert program == output
  end

  test "sample program with negative integers" do
    program = "1101,100,-1,4,0"
    output = "1101,100,-1,4,99"

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "diagnostic program" do
    Logger.info("Running TEST diagnostic program for system ID 1...")
    program = File.read!("TEST_diagnostic_program.txt")
    output = 9_219_874
    external_inputs = [1]

    {_result, _program, exit_code, _relative_base} = IntcodeComputer.run(program, external_inputs)
    assert exit_code == output
    Logger.info("Exit code TEST diagnostic program for system ID 1 = #{exit_code}")
  end

  test "runs program 1" do
    program = "1,0,0,0,99"
    output = "2,0,0,0,99"

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 2" do
    program = "2,3,0,3,99"
    output = "2,3,0,6,99"

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 3" do
    program = "2,4,4,5,99,0"
    output = "2,4,4,5,99,9801"

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 4" do
    program = "1,1,1,4,99,5,6,0,99"
    output = "30,1,1,4,2,5,6,0,99"

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 5" do
    program = "1,9,10,3,2,3,11,0,99,30,40,50"
    output = "3500,9,10,70,2,3,11,0,99,30,40,50"

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 6" do
    program = File.read!("program_for_testing_the_computer.txt")
    output = File.read!("program_for_testing_the_computer - solution.txt")

    {_result, program, _exit_code, _} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 1202" do
    assert IntcodeComputer.solution_to_program_1202() == 4_330_636
  end

  test "find solution" do
    assert IntcodeComputer.find_inputs_to_get_number(19_690_720) == 6086
  end
end
