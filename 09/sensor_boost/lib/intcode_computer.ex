# from day 05+07
defmodule IntcodeComputer do
  require Logger

  @position_mode "0"
  @immediate_mode "1"
  @relative_mode "2"

  def run(program), do: run(program, nil, 0)

  def run(program, ext_inputs, relative_base \\ 0)

  def run(program, ext_inputs, relative_base) when is_binary(program) do
    program
    |> String.split("\n", trim: true)
    |> Enum.join(",")
    |> String.replace(",,", ",")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> run(ext_inputs, relative_base)
  end

  def run(program, ext_inputs, relative_base) when is_list(program) do
    # for later removing the extended memory
    program_size = Enum.count(program)
    index = 0

    {:halt, prog, exit_code, relative_base} = run_step(program, ext_inputs, relative_base, index)

    do_handle_result({:halt, Enum.take(prog, program_size), exit_code, relative_base})
  end

  defp run_step(prog, ext_inputs, relative_base, index, exit_code \\ 0) do
    instruction = Enum.fetch!(prog, index)

    opcode = get_opcode_from_instruction(instruction)

    case opcode do
      n when n in [1, 2, 7, 8] ->
        {prog, index} = execute_opcode_for_operations(prog, index, relative_base)
        run_step(prog, ext_inputs, relative_base, index)

      3 ->
        {prog, index, external_inputs} =
          execute_opcode_for_external_inputs(prog, index, ext_inputs, relative_base)

        run_step(prog, external_inputs, relative_base, index)

      4 ->
        {prog, index, exit_code} =
          execute_opcode_for_external_output(instruction, prog, index, relative_base)

        run_step(prog, ext_inputs, relative_base, index, exit_code)

      n when n in [5, 6] ->
        {prog, index} = execute_opcode_for_jump(prog, index, relative_base)
        run_step(prog, ext_inputs, relative_base, index, exit_code)

      9 ->
        {prog, index, relative_base} =
          execute_opcode_for_relative_base_offset(instruction, prog, index, relative_base)

        run_step(prog, ext_inputs, relative_base, index, exit_code)

      99 ->
        {:halt, prog, exit_code, relative_base}

      _ ->
        run_step(prog, ext_inputs, relative_base, index + 1)
    end
  end

  defp execute_opcode_for_operations(prog, index, relative_base) do
    {prog, opcode, value1, value2, target} = get_instruction_data(prog, index, relative_base)

    operation_result =
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

    {insert_value_into_prog_at_position(prog, target, operation_result), index + 4}
  end

  defp execute_opcode_for_external_inputs(prog, index, inputs, relative_base)
       when is_nil(inputs) do
    inputs =
      IO.gets("Introduce integer: ")
      |> String.trim()
      |> String.to_integer()

    execute_opcode_for_external_inputs(prog, index, [inputs], relative_base)
  end

  defp execute_opcode_for_external_inputs(prog, index, [input | ext_inputs], relative_base) do
    [instruction, target] = Enum.slice(prog, index..(index + 1))

    {mode_param1, _, _} = get_modes_from_instruction(instruction)

    pos =
      case mode_param1 do
        @relative_mode -> target + relative_base
        @position_mode -> target
        @immediate_mode -> target
      end

    prog = insert_value_into_prog_at_position(prog, pos, input)

    {prog, index + 2, ext_inputs}
  end

  defp execute_opcode_for_external_output(instruction, prog, index, relative_base) do
    {mode_param1, _mode_param2, _mode_param3} = get_modes_from_instruction(instruction)

    source = Enum.fetch!(prog, index + 1)
    {prog, output} = fetch_value(prog, source, mode_param1, relative_base)
    output |> IO.inspect(label: "Output")

    {prog, index + 2, output}
  end

  def execute_opcode_for_jump(prog, index, relative_base) do
    {prog, opcode, value1, value2, _param3} = get_instruction_data(prog, index, relative_base)

    new_index =
      case opcode do
        # jump-if-true
        5 -> if value1 != 0, do: value2, else: index + 3
        # jump-if-false
        6 -> if value1 == 0, do: value2, else: index + 3
      end

    {prog, new_index}
  end

  def execute_opcode_for_relative_base_offset(instruction, prog, index, relative_base) do
    {mode_param1, _mode_param2, _mode_param3} = get_modes_from_instruction(instruction)

    source = Enum.fetch!(prog, index + 1)

    {prog, offset} = fetch_value(prog, source, mode_param1, relative_base)

    {prog, index + 2, relative_base + offset}
  end

  defp do_handle_result({:halt, data, exit_code, relative_base}) do
    {:halt, data |> Enum.join(","), exit_code, relative_base}
  end

  defp find_inputs_to_get({command, data}) do
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

  defp get_instruction_data(prog, index, relative_base) do
    [instruction, param1, param2, param3] = Enum.slice(prog, index..(index + 3))

    opcode = get_opcode_from_instruction(instruction)

    {mode_param1, mode_param2, mode_param3} = get_modes_from_instruction(instruction)

    {prog, value1} = fetch_value(prog, param1, mode_param1, relative_base)
    {prog, value2} = fetch_value(prog, param2, mode_param2, relative_base)
    {prog, target} = fetch_value(prog, param3, mode_param3, relative_base)

    {prog, opcode, value1, value2, target}
  end

  defp get_opcode_from_instruction(instruction) do
    rem(instruction, 100)
  end

  defp get_modes_from_instruction(instruction) do
    <<mode_param3::binary-size(1), mode_param2::binary-size(1), mode_param1::binary-size(1)>> =
      trunc(instruction / 100)
      |> Integer.to_string()
      |> String.pad_leading(3, "0")

    {mode_param1, mode_param2, mode_param3}
  end

  def fetch_value(prog, pos, mode, _relative_base) when mode == @position_mode do
    result = Enum.fetch(prog, pos)

    case result do
      {:ok, value} ->
        {prog, value}

      :error ->
        expand_prog_with_memory(prog, pos)
    end
  end

  def fetch_value(prog, pos, mode, _relative_base) when mode == @immediate_mode do
    {prog, pos}
  end

  def fetch_value(prog, pos, mode, relative_base) when mode == @relative_mode do
    pos = pos + relative_base
    result = Enum.fetch(prog, pos)

    case result do
      {:ok, value} ->
        {prog, value}

      :error ->
        expand_prog_with_memory(prog, pos)
    end
  end

  def expand_prog_with_memory(prog, pos) do
    # TODO instead of adding dummy elements and filling them with 0s, better to have stored the %{position,value} pair
    filling_value = 0
    extended_memory = for _n <- 0..(pos - Enum.count(prog)), do: filling_value

    prog_with_extended_memory =
      [extended_memory | Enum.reverse(prog)] |> Enum.reverse() |> List.flatten()

    {prog_with_extended_memory, filling_value}
  end

  def insert_value_into_prog_at_position(prog, pos, value) when pos == 0 do
    # insert at the begining
    [value] ++ Enum.slice(prog, 1..-1)
  end

  def insert_value_into_prog_at_position(prog, pos, value) when pos != 0 do
    program =
      if Enum.count(prog) < pos do
        {p, _} = expand_prog_with_memory(prog, pos)
        p
      else
        prog
      end

    # insert in between
    Enum.slice(program, 0..(pos - 1)) ++ [value] ++ Enum.slice(prog, (pos + 1)..-1)
  end

  defp find_solution_for_program(noun, verb) do
    instructions =
      File.read!("program_for_testing_the_computer.txt")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.slice(3..-1)

    {_result, program, _exit_code, _} =
      ([1, noun, verb] ++ instructions)
      |> run([])

    program
    |> String.split(",")
    |> List.first()
    |> String.to_integer()
  end

  def solution_to_program_1202 do
    find_solution_for_program(12, 2)
  end

  def find_inputs_to_get_number(number) do
    [noun, verb] = find_inputs_to_get({:run, [number, 0]})

    100 * noun + verb
  end
end
