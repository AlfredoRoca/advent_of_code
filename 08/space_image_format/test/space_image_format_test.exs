defmodule SpaceImageFormatTest do
  use ExUnit.Case
  doctest SpaceImageFormat

  test "I can count ones - 1" do
    assert SpaceImageFormat.count_ones("01010") == 2
  end

  test "I can count ones - 2" do
    assert SpaceImageFormat.count_ones("211101") == 4
  end

  test "I can count twos - 1" do
    assert SpaceImageFormat.count_twos("02220") == 3
  end

  test "I can count twos - 2" do
    assert SpaceImageFormat.count_twos("22") == 2
  end

  test "I can get a verification code from a layer" do
    assert SpaceImageFormat.verification_code("0102002201") == 6
  end

  test "I can extract the verification layer (min 0)" do
    l1 = "012012"
    l2 = "001200"
    assert SpaceImageFormat.verification_layer([l1, l2]) == l1
  end
end
