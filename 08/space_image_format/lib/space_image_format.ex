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
    get_layers(image_file)
    |> verification_layer()
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

  def get_layers(image, width \\ @width, height \\ @height) do
    case image do
      %{file: image_file} ->
        get_layers_from_file(image_file, width, height)

      _ ->
        get_layers_from_string(image, width, height)
    end
  end

  def get_layers_from_file(image_file, width, height) do
    image_file
    |> File.stream!([], width * height)
    |> Enum.to_list()
  end

  def get_layers_from_string(image_string, width, height) do
    image_string
    |> String.codepoints()
    |> Enum.chunk_every(width * height)
    |> Enum.map(&Enum.join(&1))
    |> Enum.to_list()
  end

  def blend_layers(front, back) when is_nil(front) do
    back
  end

  def blend_layers(front, back) do
    String.codepoints(front)
    |> Enum.zip(String.codepoints(back))
    |> Enum.map(fn {f, b} -> if f == "2", do: b, else: f end)
    |> Enum.join()
  end

  def process_image() do
    process_image(%{file: "puzzle_input.txt"})
    |> String.codepoints()
    |> Enum.chunk_every(@width)
    |> Enum.map(&Enum.join(&1))
    |> Enum.map(fn s -> String.replace(s, "1", "*") end)
    |> Enum.map(fn s -> String.replace(s, "0", " ") end)
    |> Enum.join("\n")
    |> IO.write()
  end

  def process_image(image, width \\ @width, height \\ @height) do
    {_, final_image} =
      get_layers(image, width, height)
      |> Enum.map_reduce(nil, fn layer, blended -> {layer, blend_layers(blended, layer)} end)

    final_image
  end
end
