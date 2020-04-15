defmodule IntcodeComputerTest do
  use ExUnit.Case, async: false
  import Mock
  require Logger

  #
  #
  # tests part 2
  #
  #

  test "sample program 1 (position mode) - equal -> true" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "8\n"
        end
      end
    ) do
      program = "3,9,8,9,10,9,4,9,99,-1,8"
      expected_code = 1
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 1 (immediate mode) - equal -> true" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "8\n"
        end
      end
    ) do
      program = "3,3,1108,-1,8,3,4,3,99"
      expected_code = 1
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 1 (position mode) - equal -> false" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "3\n"
        end
      end
    ) do
      program = "3,9,8,9,10,9,4,9,99,-1,8"
      expected_code = 0
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 1 (immediate mode) - equal -> false" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "3\n"
        end
      end
    ) do
      program = "3,3,1108,-1,8,3,4,3,99"
      expected_code = 0
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 2 (position mode) - less than -> true" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "3\n"
        end
      end
    ) do
      program = "3,9,7,9,10,9,4,9,99,-1,8"
      expected_code = 1
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 2 (position mode) - less than -> false" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "42\n"
        end
      end
    ) do
      program = "3,9,7,9,10,9,4,9,99,-1,8"
      expected_code = 0
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 2 (immediate mode) - less than -> true" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "3\n"
        end
      end
    ) do
      program = "3,3,1107,-1,8,3,4,3,99"
      expected_code = 1
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "variant program 2 (immediate mode) - less than -> true" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "3\n"
        end
      end
    ) do
      program = "3,3,1107,-1,8,3,4,3,99"
      new_prog = "3,3,1107,1,8,3,4,3,99"
      {_result, program, exit_code} = IntcodeComputer.run(program)
      assert program == new_prog
      assert exit_code == 1
    end
  end

  test "sample program 2 (immediate mode) - less than -> false" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "42\n"
        end
      end
    ) do
      program = "3,3,1107,-1,8,3,4,3,99"
      expected_code = 0
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 3 (position mode) - jump input 0 " do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "0\n"
        end
      end
    ) do
      program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
      expected_code = 0
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 3 (position mode) - jump input non 0" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "42\n"
        end
      end
    ) do
      program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
      expected_code = 1
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 3 (immediate mode) - jump input 0 " do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "0\n"
        end
      end
    ) do
      program = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
      expected_code = 0
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 3 (immediate mode) - jump input non 0" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "42\n"
        end
      end
    ) do
      program = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
      expected_code = 1
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 4 - combined below 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "2\n"
        end
      end
    ) do
      program = """
      3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,
      21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
      """

      expected_code = 999
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 4 - combined equals 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "8\n"
        end
      end
    ) do
      program = """
      3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,
      21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
      """

      expected_code = 1000
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "sample program 4 - combined above 8" do
    # The above example program uses an input instruction to ask for a single number.
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8,
    # or output 1001 if the input value is greater than 8.
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "42\n"
        end
      end
    ) do
      program = """
      3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,
      21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
      """

      expected_code = 1001
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == expected_code
    end
  end

  test "program with console output (position mode)" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "50\n"
        end
      end
    ) do
      program = "3,0,4,0,99"
      output = "50,0,4,0,99"

      {_result, program, _exit_code} = IntcodeComputer.run(program)

      assert program == output
    end
  end

  test "program with console output (inmediate mode)" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "50\n"
        end
      end
    ) do
      program = "3,0,104,42,99"
      output = "50,0,104,42,99"
      expected_code = 42

      {_result, program, exit_code} = IntcodeComputer.run(program)

      assert exit_code == expected_code
      assert program == output
    end
  end

  @tag final: true
  test "diagnostic program for the ship's thermal radiator controller - System ID 5" do
    Logger.info(
      "Running TEST diagnostic program for the ship's thermal radiator controller - System ID 5\n Introduce integer 5..."
    )

    program = File.read!("TEST_diagnostic_program.txt")

    expected_code = 5_893_654

    {_result, _program, exit_code} = IntcodeComputer.run(program)
    assert exit_code == expected_code
    Logger.info("Exit code ship's thermal radiator controller diagnostic program = #{exit_code}")
  end

  #
  #
  # tests part 1
  #
  #
  test "program auto halting" do
    program = "1002,4,3,4,33"
    output = "1002,4,3,4,99"
    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "program with console input" do
    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "50\n"
        end
      end
    ) do
      program = "3,2,0,99"
      output = "3,2,50,99"
      {_result, program, _exit_code} = IntcodeComputer.run(program)
      assert program == output
    end
  end

  test "sample program with negative integers" do
    program = "1101,100,-1,4,0"
    output = "1101,100,-1,4,99"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "diagnostic program" do
    Logger.info("Running TEST diagnostic program for system ID 1...")
    program = File.read!("TEST_diagnostic_program.txt")
    output = 9_219_874

    with_mock(IO,
      gets: fn prompt ->
        case prompt do
          "Introduce integer: " -> "1\n"
        end
      end
    ) do
      {_result, _program, exit_code} = IntcodeComputer.run(program)
      assert exit_code == output
      Logger.info("Exit code TEST diagnostic program for system ID 1 = #{exit_code}")
    end
  end

  #
  #
  # tests for computer day 02
  #
  #
  test "runs program 1" do
    program = "1,0,0,0,99"
    output = "2,0,0,0,99"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 2" do
    program = "2,3,0,3,99"
    output = "2,3,0,6,99"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 3" do
    program = "2,4,4,5,99,0"
    output = "2,4,4,5,99,9801"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 4" do
    program = "1,1,1,4,99,5,6,0,99"
    output = "30,1,1,4,2,5,6,0,99"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 5" do
    program = "1,9,10,3,2,3,11,0,99,30,40,50"
    output = "3500,9,10,70,2,3,11,0,99,30,40,50"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 6" do
    program = File.read!("program.txt")
    output = File.read!("solution_to_program_file.txt")

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  test "runs program 1202" do
    assert IntcodeComputer.solution_to_program_1202() == 4_330_636
  end

  test "find solution" do
    assert IntcodeComputer.find_inputs_to_get_number(19_690_720) == 6086
  end
end
