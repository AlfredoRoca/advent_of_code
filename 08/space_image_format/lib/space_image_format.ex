defmodule SpaceImageFormat do
  @moduledoc """
  Documentation for SpaceImageFormat.
  """

  @width 25
  @height 6

  def returns_layers() do
    # layers_by_rows = File.stream!("puzzle_input.txt", [], 25) |> Stream.chunk_every(6) |> Enum.to_list()
    File.stream!("puzzle_input.txt", [], @width * @height) |> Enum.to_list()
  end
end
