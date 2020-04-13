defmodule IntcodeComputerTest do
  use ExUnit.Case, async: false
  import Mock
  require Logger

  @tag t: true
  test "program auto halting" do
    program = "1002,4,3,4,33"
    output = "1002,4,3,4,99"
    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  @tag t: true
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

  @tag t: true
  test "program with console output" do
    Logger.info("Running program with output...")

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

  @tag t: true
  test "sample program with negative integers" do
    program = "1101,100,-1,4,0"
    output = "1101,100,-1,4,99"

    {_result, program, _exit_code} = IntcodeComputer.run(program)
    assert program == output
  end

  @tag t: true
  @tag t1: true
  test "diagnostic program" do
    Logger.info("Running diagnostic program...")
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
