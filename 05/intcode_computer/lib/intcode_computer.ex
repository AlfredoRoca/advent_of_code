defmodule IntcodeComputer do
  def solution_to_program_1202 do
    find_solution_for_program(12, 2)
  end

  def find_inputs_to_get_number(number) do
    [noun, verb] = find_inputs_to_get({:run, [number, 0]})

    100 * noun + verb
  end

  def find_inputs_to_get({command, data}) do
    case command do
      :run ->
        [number, noun] = data
        sol = find_solution_for_program(noun, 0)

        next_command =
          case sol - number do
            n when n < 0 ->
              {:run, [number, noun + 1]}

            0 ->
              {:solution, [noun, 0]}

            n when n > 0 ->
              prev_sol = find_solution_for_program(noun - 1, 0)
              {:solution, [noun - 1, number - prev_sol]}
          end

        find_inputs_to_get(next_command)

      :solution ->
        data
    end
  end

  def find_solution_for_program(noun, verb) do
    instructions =
      File.read!("program.txt")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.slice(3..-1)

    ([1, noun, verb] ++ instructions)
    |> run()
    |> String.split(",")
    |> List.first()
    |> String.to_integer()
  end

  def run(program) when is_list(program) do
    run_step(program, 0)
    |> Enum.join(",")
  end

  def run(program) when is_binary(program) do
    program
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> run()
  end

  def run_step(prog, index) do
    opcode = Enum.fetch!(prog, index)

    case opcode do
      n when n in [1, 2] ->
        new_prog = execute_opcode(opcode, prog, index)
        run_step(new_prog, index + 4)

      99 ->
        prog
    end
  end

  def execute_opcode(opcode, prog, index) do
    [_pos0, pos1, pos2, pos3] = Enum.slice(prog, index..(index + 3))
    value1 = Enum.fetch!(prog, pos1)
    value2 = Enum.fetch!(prog, pos2)

    operation =
      case opcode do
        1 -> value1 + value2
        2 -> value1 * value2
      end

    if pos3 == 0 do
      [operation] ++ Enum.slice(prog, 1..-1)
    else
      Enum.slice(prog, 0..(pos3 - 1)) ++ [operation] ++ Enum.slice(prog, (pos3 + 1)..-1)
    end
  end
end
