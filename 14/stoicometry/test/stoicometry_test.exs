defmodule StoicometryTest do
  use ExUnit.Case
  doctest Stoicometry
  import Assertions

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

  test "formula 2" do
    recipe = """
      9 ORE => 2 A
      8 ORE => 3 B
      7 ORE => 5 C
      3 A, 4 B => 1 AB
      5 B, 7 C => 1 BC
      4 C, 1 A => 1 CA
      2 AB, 3 BC, 4 CA => 1 FUEL
    """

    assert Stoicometry.ores_for_one_fuel(recipe) == 165
  end

  test "formula 3" do
    recipe = """
      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    """

    assert Stoicometry.ores_for_one_fuel(recipe) == 13312
  end

  test "formula 4" do
    recipe = """
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
    """

    assert Stoicometry.ores_for_one_fuel(recipe) == 180_697
  end

  test "formula 5" do
    recipe = """
      171 ORE => 8 CNZTR
      7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
      114 ORE => 4 BHXH
      14 VRPVC => 6 BMBT
      6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
      6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
      15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
      13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
      5 BMBT => 4 WPTQ
      189 ORE => 9 KTJDG
      1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
      12 VRPVC, 27 CNZTR => 2 XDBXC
      15 KTJDG, 12 BHXH => 5 XCVML
      3 BHXH, 2 VRPVC => 7 MZWV
      121 ORE => 7 VRPVC
      7 XCVML => 6 RJRHP
      5 BHXH, 4 VRPVC => 5 LTCX
    """

    assert Stoicometry.ores_for_one_fuel(recipe) == 2_210_736
  end

  # tests of internals
  test "formula 1: extracts the base elements from a recipe" do
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

  test "formula 4: extracts the base elements from a recipe" do
    recipe = """
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert_lists_equal(Stoicometry.base_elements(parsed_recipe), [
      {"NVRVD", %{formula: [%{chemical: "ORE", quantity: "139"}], quantity: 4}},
      {"JNWZP", %{formula: [%{chemical: "ORE", quantity: "144"}], quantity: 7}},
      {"MNCFX", %{formula: [%{chemical: "ORE", quantity: "145"}], quantity: 6}},
      {"VJHF", %{formula: [%{chemical: "ORE", quantity: "176"}], quantity: 6}}
    ])
  end

  test "formula 1: decomposes compound elements into base elements" do
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

  test "formula 4: decomposes compound elements into base elements" do
    recipe = """
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

    assert_lists_equal(
      Stoicometry.decompose(parsed_recipe, %{chemical: "VPVL", quantity: 8}),
      [
        %{chemical: "NVRVD", quantity: 17},
        %{chemical: "JNWZP", quantity: 3}
      ]
    )
  end

  test "formula 1: determines if a chemical element is a base element" do
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

  test "formula 4: determines if a chemical element is a base element" do
    recipe = """
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
    """

    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)
    chemical = "MNCFX"
    assert Stoicometry.chemical_is_base_element(parsed_recipe, chemical)

    chemical = "CXFTF"
    refute Stoicometry.chemical_is_base_element(parsed_recipe, chemical)
  end

  test "formula 1: reduces the results summing up the quantities" do
    list_of_chemicals = [
      %{chemical: "A", quantity: 14},
      [%{chemical: "A", quantity: 14}, %{chemical: "B", quantity: 2}]
    ]

    assert Stoicometry.reduce_quantities(list_of_chemicals) == [
             %{chemical: "A", quantity: 28},
             %{chemical: "B", quantity: 2}
           ]
  end

  test "formula 4: reduces the results summing up the quantities" do
    list_of_chemicals = [
      %{chemical: "VPVL", quantity: 14},
      %{chemical: "RFSQX", quantity: 10},
      [%{chemical: "VPVL", quantity: 8}, %{chemical: "VJHF", quantity: 2}],
      [
        %{chemical: "VJHF", quantity: 5},
        %{chemical: "RFSQX", quantity: 2},
        %{chemical: "VPVL", quantity: 5}
      ]
    ]

    assert_lists_equal(Stoicometry.reduce_quantities(list_of_chemicals), [
      %{chemical: "VPVL", quantity: 27},
      %{chemical: "VJHF", quantity: 7},
      %{chemical: "RFSQX", quantity: 12}
    ])
  end

  test "formula on file" do
    assert Stoicometry.ores_for_one_fuel(File.read!("input.txt")) == 654_909
  end

  # test "extracts the compound elements from a recipe" do
  #   recipe = """
  #     10 ORE => 10 A
  #     1 ORE => 1 B
  #     7 A, 1 B => 1 C
  #     7 A, 1 C => 1 D
  #     7 A, 1 D => 1 E
  #     7 A, 1 E => 1 FUEL
  #   """

  #   parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

  #   assert Stoicometry.compound_elements(parsed_recipe) == [
  #            {"C",
  #             %{
  #               formula: [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}],
  #               quantity: 1
  #             }},
  #            {"D",
  #             %{
  #               formula: [%{chemical: "A", quantity: "7"}, %{chemical: "C", quantity: "1"}],
  #               quantity: 1
  #             }},
  #            {"E",
  #             %{
  #               formula: [%{chemical: "A", quantity: "7"}, %{chemical: "D", quantity: "1"}],
  #               quantity: 1
  #             }}
  #          ]
  # end

  # test "extracts the fuel element from a recipe" do
  #   recipe = """
  #     10 ORE => 10 A
  #     1 ORE => 1 B
  #     7 A, 1 B => 1 C
  #     7 A, 1 C => 1 D
  #     7 A, 1 D => 1 E
  #     7 A, 1 E => 1 FUEL
  #   """

  #   parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

  #   assert Stoicometry.fuel(parsed_recipe) == [
  #            {"FUEL",
  #             %{
  #               formula: [%{chemical: "A", quantity: "7"}, %{chemical: "E", quantity: "1"}],
  #               quantity: 1
  #             }}
  #          ]
  # end

  # test "determines if all elements are base elements (false)" do
  #   recipe = """
  #     10 ORE => 10 A
  #     1 ORE => 1 B
  #     7 A, 1 B => 1 C
  #     7 A, 1 C => 1 D
  #     7 A, 1 D => 1 E
  #     7 A, 1 E => 1 FUEL
  #   """

  #   parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

  #   assert Stoicometry.all_base_elements?(parsed_recipe) == false
  # end

  # test "determines if all elements are base elements (true)" do
  #   recipe = """
  #     10 ORE => 10 A
  #     1 ORE => 1 B
  #     7 A, 1 B => 1 FUEL
  #   """

  #   parsed_recipe = Stoicometry.get_parsed_recipe(recipe)

  #   assert Stoicometry.all_base_elements?(parsed_recipe) == true
  # end
end
