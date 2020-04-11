defmodule SecureContainerTest do
  use ExUnit.Case

  test "sample meets criteria" do
    pw = 111_111
    assert SecureContainer.meets_criteria?(pw) == true
  end

  test "smaple does not meet criteria due decreasing digits" do
    pw = 223_450
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "smaple does not meet criteria due no double digits" do
    pw = 123_789
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "greets the world" do
    input_range = 147_981..691_423
    quantity = 1790
    assert SecureContainer.how_many_pw(input_range) == quantity
  end
end
