defmodule Memory do
  @absolute "0"
  @immediate "1"
  @relative "2"
  @default_value 0

  def new() do
    Map.new()
  end

  def read_program_into_memory(file: program_file) do
    File.read!(program_file)
    |> String.split("\n", trim: true)
    |> Enum.join(",")
    |> String.replace(",,", ",")
    |> read_program_into_memory()
  end

  def read_program_into_memory(program_string) do
    instruction_list =
      program_string
      |> String.replace("\n,", "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {memory, _last_pos} =
      Enum.reduce(instruction_list, {Map.new(), 0}, fn instruction, {memory, position} ->
        {write(memory, position, instruction, @immediate, 0), position + 1}
      end)

    memory
  end

  def read(memory, position, mode, relative_base) do
    case mode do
      @immediate ->
        Map.get(memory, position, @default_value)

      @absolute ->
        address = Map.get(memory, position, @default_value)
        Map.get(memory, address, @default_value)

      @relative ->
        address = Map.get(memory, position, @default_value) + relative_base
        Map.get(memory, address, @default_value)
    end
  end

  def write(memory, position, value, mode, relative_base) do
    case mode do
      @immediate ->
        Map.put(memory, position, value)

      @absolute ->
        Map.put(memory, position, value)

      @relative ->
        Map.put(memory, position + relative_base, value)
    end
  end

  def dump_as_string(memory) do
    dump_as_list(memory) |> Enum.join(",")
  end

  def dump_as_list(memory) do
    Map.to_list(memory) |> Enum.map(fn {_k, v} -> v end)
  end

  def mode_immediate, do: @immediate
  def mode_absolute, do: @absolute
  def mode_relative, do: @relative
end
