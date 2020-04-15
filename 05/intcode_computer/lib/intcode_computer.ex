defmodule IntcodeComputer do
  require Logger

  @position_mode "0"
  @immediate_mode "1"

  def run_diagnostic_program(program) do
    run(program)
  end

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

    {_result, program, _exit_code} =
      ([1, noun, verb] ++ instructions)
      |> run()

    program
    |> String.split(",")
    |> List.first()
    |> String.to_integer()
  end

  def run(program) when is_list(program) do
    {result, data, exit_code} = run_step(program, 0)

    case result do
      :halt -> {:halt, data |> Enum.join(","), exit_code}
    end
  end

  def run(program) when is_binary(program) do
    program
    |> String.split("\n", trim: true)
    |> Enum.join(",")
    |> String.replace(",,", ",")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> run()
  end

  def run_step(prog, index, exit_code \\ 0) do
    instruction = Enum.fetch!(prog, index)
    opcode = get_opcode_from_instruction(instruction)

    case opcode do
      n when n in [1, 2, 7, 8] ->
        {prog, index} = execute_opcode_for_operations(prog, index)
        run_step(prog, index)

      3 ->
        {prog, index} = execute_opcode_for_external_input(prog, index)
        run_step(prog, index)

      4 ->
        {prog, index, exit_code} = execute_opcode_for_external_output(instruction, prog, index)
        run_step(prog, index, exit_code)

      n when n in [5, 6] ->
        {prog, index} = execute_opcode_for_jump(prog, index)
        run_step(prog, index, exit_code)

      99 ->
        {:halt, prog, exit_code}

      _ ->
        run_step(prog, index + 1)
    end
  end

  def execute_opcode_for_operations(prog, index) do
    {opcode, value1, value2, param3} = get_instruction_data(prog, index)

    operation =
      case opcode do
        1 ->
          value1 + value2

        2 ->
          value1 * value2

        7 ->
          if value1 < value2, do: 1, else: 0

        8 ->
          if value1 == value2, do: 1, else: 0
      end

    {insert_value_into_prog_at_position(prog, param3, operation), index + 4}
  end

  def execute_opcode_for_external_input(prog, index) do
    # returns the new prog and the next position in the prog
    input =
      IO.gets("Introduce integer: ")
      |> String.trim()
      |> String.to_integer()

    target = Enum.fetch!(prog, index + 1)

    {insert_value_into_prog_at_position(prog, target, input), index + 2}
  end

  def execute_opcode_for_external_output(instruction, prog, index) do
    {mode_param1, _mode_param2} =
      instruction
      |> get_modes_from_instruction()

    source = Enum.fetch!(prog, index + 1)
    exit_code = fetch_value(prog, source, mode_param1)

    {prog, index + 2, exit_code}
  end

  def execute_opcode_for_jump(prog, index) do
    {opcode, value1, value2, _param3} = get_instruction_data(prog, index)

    new_index =
      case opcode do
        # jump-if-true
        5 -> if value1 != 0, do: value2, else: index + 3
        # jump-if-false
        6 -> if value1 == 0, do: value2, else: index + 3
      end

    {prog, new_index}
  end

  defp get_instruction_data(prog, index) do
    [instruction, param1, param2, param3] = Enum.slice(prog, index..(index + 3))

    opcode =
      instruction
      |> get_opcode_from_instruction()

    {mode_param1, mode_param2} =
      instruction
      |> get_modes_from_instruction()

    value1 = fetch_value(prog, param1, mode_param1)
    value2 = fetch_value(prog, param2, mode_param2)

    {opcode, value1, value2, param3}
  end

  defp get_opcode_from_instruction(instruction) do
    rem(instruction, 100)
  end

  defp get_modes_from_instruction(instruction) do
    <<mode_param2::binary-size(1), mode_param1::binary-size(1)>> =
      trunc(instruction / 100)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    {mode_param1, mode_param2}
  end

  defp fetch_value(prog, pos, mode) when mode == @position_mode do
    Enum.fetch!(prog, pos)
  end

  defp fetch_value(_prog, pos, mode) when mode == @immediate_mode do
    pos
  end

  def insert_value_into_prog_at_position(prog, pos, value) when pos == 0 do
    # insert at the begining
    [value] ++ Enum.slice(prog, 1..-1)
  end

  def insert_value_into_prog_at_position(prog, pos, value) when pos != 0 do
    # insert in between
    Enum.slice(prog, 0..(pos - 1)) ++ [value] ++ Enum.slice(prog, (pos + 1)..-1)
  end
end
