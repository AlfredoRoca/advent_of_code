defmodule SpaceImageFormat do
  @moduledoc """
  Documentation for SpaceImageFormat.
  """

  @width 25
  @height 6

  def verify_image() do
    verification_code(verification_layer("puzzle_input.txt"))
  end

  def verification_layer(image_file) when is_binary(image_file) do
    File.stream!(image_file, [], @width * @height)
    |> Enum.to_list()
    |> verification_layer()

    # |> Enum.min_by(fn i -> String.split(i, "0") |> Enum.count() end)
  end

  def verification_layer(image) when is_list(image) do
    image
    |> Enum.min_by(fn i -> String.split(i, "0") |> Enum.count() end)
  end

  def verification_code(verification_layer) do
    count_ones(verification_layer) * count_twos(verification_layer)
  end

  def count_ones(layer) do
    parts = layer |> String.split("1") |> Enum.count()
    parts - 1
  end

  def count_twos(layer) do
    parts = layer |> String.split("2") |> Enum.count()
    parts - 1
  end
end
