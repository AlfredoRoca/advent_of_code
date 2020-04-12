defmodule SecureContainerTest do
  use ExUnit.Case

  test "sample 1 meets criteria" do
    pw = 112_233
    assert SecureContainer.meets_criteria?(pw) == true
  end

  test "sample 2 meets criteria" do
    pw = 111_122
    assert SecureContainer.meets_criteria?(pw) == true
  end

  @tag t: true
  test "sample 3 meets criteria" do
    pw = 112_222
    assert SecureContainer.meets_criteria?(pw) == true
  end

  test "sample 4 meets criteria" do
    pw = 111_223
    assert SecureContainer.meets_criteria?(pw) == true
  end

  test "sample does not meet criteria due decreasing digits" do
    pw = 223_450
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "sample does not meet criteria due no double digits" do
    pw = 123_789
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "sample 1 does not meet criteria due double digits not even number" do
    pw = 111_234
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "sample 2 does not meet criteria due double digits not even number" do
    pw = 123_444
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "sample 3 does not meet criteria due double digits not even number" do
    pw = 144_444
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "sample 4 does not meet criteria due double digits not even number" do
    pw = 333_444
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "sample 5 does not meet criteria due no double" do
    pw = 111_111
    assert SecureContainer.meets_criteria?(pw) == false
  end

  test "greets the world" do
    input_range = 147_981..691_423
    quantity = 1206
    assert SecureContainer.how_many_pw(input_range) == quantity
  end
end
