defmodule Computer do
  def solution_to_program_1202 do
    p1202 =
      File.read!("program.txt")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    ([1, 12, 2] ++ Enum.slice(p1202, 3..-1))
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
