defmodule Program do
  defstruct memory: Memory.new(), inputs: [], outputs: [], relative_base: 0, position: 0

  def(new(file: instructions)) do
    %Program{memory: Memory.read_program_into_memory(file: instructions)}
  end

  def(new(instructions)) do
    %Program{memory: Memory.read_program_into_memory(instructions)}
  end

  def print_outputs(program) do
    program.outputs
  end

  def run(program, inputs \\ [], relative_base \\ 0) do
    {_command, program} =
      tick(%{program | inputs: inputs, relative_base: relative_base, position: 0})

    program
  end

  def tick(program) do
    {command, program} = execute_instruction(program)

    {command, program} =
      case command do
        :continue ->
          tick(program)

        _ ->
          {:halt, program}
      end

    {command, program}
  end

  def execute_instruction(program) do
    opcode = get_opcode(program)

    case opcode do
      1 -> {:continue, execute_add(program)}
      2 -> {:continue, execute_mult(program)}
      3 -> {:continue, execute_input(program)}
      4 -> {:continue, execute_output(program)}
      5 -> {:continue, execute_jump_if_non_zero(program)}
      6 -> {:continue, execute_jump_if_zero(program)}
      7 -> {:continue, execute_less(program)}
      8 -> {:continue, execute_equal(program)}
      9 -> {:continue, execute_update_relative_base(program)}
      99 -> {:halt, program}
      _ -> {:continue, execute_nop(program)}
    end
  end

  # instructions code
  def execute_add(program) do
    {mode_param1, mode_param2, mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)
    value2 = Memory.read(program.memory, program.position + 2, mode_param2, program.relative_base)

    destination =
      Memory.read(
        program.memory,
        program.position + 3,
        Memory.mode_immediate(),
        program.relative_base
      )

    %Program{
      program
      | memory:
          Memory.write(
            program.memory,
            destination,
            value1 + value2,
            mode_param3,
            program.relative_base
          ),
        position: program.position + 4
    }
  end

  def execute_mult(program) do
    {mode_param1, mode_param2, mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)
    value2 = Memory.read(program.memory, program.position + 2, mode_param2, program.relative_base)

    destination =
      Memory.read(
        program.memory,
        program.position + 3,
        Memory.mode_immediate(),
        program.relative_base
      )

    %Program{
      program
      | memory:
          Memory.write(
            program.memory,
            destination,
            value1 * value2,
            mode_param3,
            program.relative_base
          ),
        position: program.position + 4
    }
  end

  def execute_output(program) do
    {mode_param1, _mode_param2, _mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)

    %Program{
      program
      | outputs: program.outputs ++ [value1],
        position: program.position + 2
    }
  end

  def execute_input(program) do
    {mode_param1, _mode_param2, _mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    destination =
      Memory.read(
        program.memory,
        program.position + 1,
        Memory.mode_immediate(),
        program.relative_base
      )

    [input | remaining_inputs] = program.inputs

    %Program{
      program
      | memory:
          Memory.write(
            program.memory,
            destination,
            input,
            mode_param1,
            program.relative_base
          ),
        position: program.position + 2,
        inputs: remaining_inputs
    }
  end

  def execute_jump_if_zero(program) do
    {mode_param1, mode_param2, _mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 =
      Memory.read(
        program.memory,
        program.position + 1,
        mode_param1,
        program.relative_base
      )

    destination =
      if value1 == 0 do
        Memory.read(
          program.memory,
          program.position + 2,
          mode_param2,
          program.relative_base
        )
      else
        program.position + 3
      end

    %Program{
      program
      | position: destination
    }
  end

  def execute_jump_if_non_zero(program) do
    {mode_param1, mode_param2, _mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)

    destination =
      if value1 != 0 do
        Memory.read(
          program.memory,
          program.position + 2,
          mode_param2,
          program.relative_base
        )
      else
        program.position + 3
      end

    %Program{
      program
      | position: destination
    }
  end

  def execute_less(program) do
    {mode_param1, mode_param2, mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)
    value2 = Memory.read(program.memory, program.position + 2, mode_param2, program.relative_base)

    destination =
      Memory.read(
        program.memory,
        program.position + 3,
        Memory.mode_immediate(),
        program.relative_base
      )

    comparition = if value1 < value2, do: 1, else: 0

    %Program{
      program
      | memory:
          Memory.write(
            program.memory,
            destination,
            comparition,
            mode_param3,
            program.relative_base
          ),
        position: program.position + 4
    }
  end

  def execute_equal(program) do
    {mode_param1, mode_param2, mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)
    value2 = Memory.read(program.memory, program.position + 2, mode_param2, program.relative_base)

    destination =
      Memory.read(
        program.memory,
        program.position + 3,
        Memory.mode_immediate(),
        program.relative_base
      )

    comparition = if value1 == value2, do: 1, else: 0

    %Program{
      program
      | memory:
          Memory.write(
            program.memory,
            destination,
            comparition,
            mode_param3,
            program.relative_base
          ),
        position: program.position + 4
    }
  end

  def execute_update_relative_base(program) do
    {mode_param1, _mode_param2, _mode_param3} =
      get_modes_from_instruction(read_instruction(program))

    value1 = Memory.read(program.memory, program.position + 1, mode_param1, program.relative_base)

    %Program{
      program
      | relative_base: program.relative_base + value1,
        position: program.position + 2
    }
  end

  def execute_nop(program) do
    %Program{
      program
      | position: program.position + 1
    }
  end

  # functions
  def get_opcode(program) do
    get_opcode_from_instruction(read_instruction(program))
  end

  def read_instruction(program) do
    Memory.read(program.memory, program.position, Memory.mode_immediate(), 0)
  end

  def get_opcode_from_instruction(instruction) do
    rem(instruction, 100)
  end

  def get_modes_from_instruction(instruction) do
    <<mode_param3::binary-size(1), mode_param2::binary-size(1), mode_param1::binary-size(1)>> =
      trunc(instruction / 100)
      |> Integer.to_string()
      |> String.pad_leading(3, "0")

    {mode_param1, mode_param2, mode_param3}
  end

  def do_handle_result(program) do
    {:halt, program}
  end
end
