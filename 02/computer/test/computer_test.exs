defmodule ComputerTest do
  use ExUnit.Case

  test "runs program 1" do
    program = "1,0,0,0,99"
    output = "2,0,0,0,99"

    assert Computer.run(program) == output
  end

  test "runs program 2" do
    program = "2,3,0,3,99"
    output = "2,3,0,6,99"

    assert Computer.run(program) == output
  end

  test "runs program 3" do
    program = "2,4,4,5,99,0"
    output = "2,4,4,5,99,9801"

    assert Computer.run(program) == output
  end

  test "runs program 4" do
    program = "1,1,1,4,99,5,6,0,99"
    output = "30,1,1,4,2,5,6,0,99"

    assert Computer.run(program) == output
  end

  test "runs program 5" do
    program = "1,9,10,3,2,3,11,0,99,30,40,50"
    output = "3500,9,10,70,2,3,11,0,99,30,40,50"

    assert Computer.run(program) == output
  end

  test "runs program 6" do
    program = File.read!("program.txt")
    output = File.read!("solution_to_program_file.txt")

    assert Computer.run(program) == output
  end

  test "runs program 1202" do
    assert Computer.solution_to_program_1202() == 4_330_636
  end

  test "find solution" do
    assert Computer.find_inputs_to_get_number(19_690_720) == 6086
  end
end
