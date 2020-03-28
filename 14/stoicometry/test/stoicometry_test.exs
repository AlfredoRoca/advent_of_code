defmodule StoicometryTest do
  use ExUnit.Case
  doctest Stoicometry

  test "formula 1" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    assert Stoicometry.ores_for_one_fuel(recipe) == 31
  end

  test "extracts the base elements from a recipe" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert Stoicometry.base_elements(parsed_recipe) == [
             {"A", %{formula: [%{chemical: "ORE", quantity: "10"}], quantity: 10}},
             {"B", %{formula: [%{chemical: "ORE", quantity: "1"}], quantity: 1}}
           ]
  end

  test "extracts the compound elements from a recipe" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert Stoicometry.compound_elements(parsed_recipe) == [
             {"C",
              %{
                formula: [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}],
                quantity: 1
              }},
             {"D",
              %{
                formula: [%{chemical: "A", quantity: "7"}, %{chemical: "C", quantity: "1"}],
                quantity: 1
              }},
             {"E",
              %{
                formula: [%{chemical: "A", quantity: "7"}, %{chemical: "D", quantity: "1"}],
                quantity: 1
              }}
           ]
  end

  test "extracts the fuel element from a recipe" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert Stoicometry.fuel(parsed_recipe) == [
             {"FUEL",
              %{
                formula: [%{chemical: "A", quantity: "7"}, %{chemical: "E", quantity: "1"}],
                quantity: 1
              }}
           ]
  end

  test "determines if a chemical element is a base element" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)
    chemical = "A"
    assert Stoicometry.chemical_is_base_element(parsed_recipe, chemical)

    chemical = "E"
    refute Stoicometry.chemical_is_base_element(parsed_recipe, chemical)
  end

  test "determines if all elements are base elements (false)" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert Stoicometry.all_base_elements?(parsed_recipe) == false
  end

  test "determines if all elements are base elements (true)" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert Stoicometry.all_base_elements?(parsed_recipe) == true
  end

  test "decomposes compound elements into base elements" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert Stoicometry.decompose(parsed_recipe, %{chemical: "C", quantity: 2}) == [
             %{chemical: "A", quantity: 14},
             %{chemical: "B", quantity: 2}
           ]

    assert Stoicometry.decompose(parsed_recipe, %{chemical: "D", quantity: 2}) == [
             %{chemical: "A", quantity: 28},
             %{chemical: "B", quantity: 2}
           ]

    assert Stoicometry.decompose(parsed_recipe, %{chemical: "FUEL", quantity: 1}) == [
             %{chemical: "A", quantity: 28},
             %{chemical: "B", quantity: 1}
           ]
  end

  test "reduces the results summing up the quantities" do
    recipe = """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    list_of_chemicals = [
      %{chemical: "A", quantity: 14},
      [%{chemical: "A", quantity: 14}, %{chemical: "B", quantity: 2}]
    ]

    assert Stoicometry.reduce_quantities(list_of_chemicals) == [
             %{chemical: "A", quantity: 28},
             %{chemical: "B", quantity: 2}
           ]
  end
end
