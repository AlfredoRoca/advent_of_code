defmodule Stoicometry do
  require IEx

  def ores_for_one_fuel(recipe) do
    parsed_recipe = Stoicometry.get_parsed_recipe(recipe)
    base_elements = Stoicometry.base_elements(parsed_recipe)
    parsed_recipe
    |> Stoicometry.decompose(%{chemical: "FUEL", quantity: 1})
    |> Enum.map(fn %{chemical: chemical, quantity: quantity_needed} ->
      {_base_name, %{formula: base_formula, quantity: base_quantity}} =
      Enum.find(base_elements, fn {name, _formula} -> name == chemical end)
      trunc(Float.ceil(quantity_needed / base_quantity)) * String.to_integer(List.first(base_formula).quantity)
    end)
    |> Enum.reduce(fn x, acc -> x + acc end)
  end

  def decompose(parsed_recipe, %{chemical: chemical, quantity: quantity_needed})
      when is_binary(quantity_needed) do
    decompose(parsed_recipe, %{chemical: chemical, quantity: String.to_integer(quantity_needed)})
  end

  def decompose(parsed_recipe, %{chemical: chemical, quantity: quantity_needed}) do
    # %{chemical: "C", quantity: "2"}
    {quantity_equivalence, list_of_components} = get_formula_for(parsed_recipe, chemical)
    # {1, [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}]

    num_batches = trunc(Float.ceil(quantity_needed / quantity_equivalence))

    Enum.map(list_of_components, fn %{chemical: chemical, quantity: quantity} = _component ->
      quantity_needed = num_batches * String.to_integer(quantity)
      ch = %{chemical: chemical, quantity: quantity_needed}

      if chemical_is_base_element(parsed_recipe, chemical) do
        ch
      else
        decompose(parsed_recipe, %{chemical: chemical, quantity: quantity_needed})
      end
    end)
    |> reduce_quantities()
  end

  def reduce_quantities(list_of_chemicals) do
    # [
    #   %{chemical: "A", quantity: 14},
    #   %{chemical: "A", quantity: 14},
    #   %{chemical: "B", quantity: 2}
    # ]
    list_of_chemicals
    |> List.flatten()
    |> Enum.sort_by(& &1.chemical)
    |> Enum.reduce(%{}, fn x, acc ->
      Map.update(acc, x.chemical, x.quantity, &(&1 + x.quantity))
    end)
    |> normalize_map_of_chemicals
  end

  def normalize_map_of_chemicals(map) do
    # %{"A" => 18, "B" => 7}
    Enum.map(Map.keys(map), fn key ->
      %{chemical: key, quantity: Map.get(map, key)}
    end)
  end

  def chemical_is_base_element(parsed_recipe, chemical) do
    Enum.filter(base_elements(parsed_recipe), &match?({^chemical, _}, &1))
    |> Enum.any?()
  end

  def get_parsed_recipe(recipe) do
    recipe
    |> parse_recipe()
  end

  def fuel(parsed_recipe) do
    parsed_recipe
    |> Enum.filter(&match?({"FUEL", _}, &1))

    # [
    #   {"FUEL",
    #    %{
    #      formula: [%{chemical: "A", quantity: "7"}, %{chemical: "E", quantity: "1"}],
    #      quantity: 1
    #    }}
    # ]
  end

  def get_formula_for(parsed_recipe, %{chemical: chemical, quantity: _quantity}) do
    # %{chemical: "C", quantity: "1"}
    get_formula_for(parsed_recipe, chemical)
  end

  @spec get_formula_for(Enumerable.t(), String.t()) :: tuple()
  def get_formula_for(parsed_recipe, chemical) do
    element =
      Enum.filter(parsed_recipe, &match?({^chemical, _}, &1))
      |> List.first()

    # {"A", %{formula: [%{chemical: "ORE", quantity: "10"}], quantity: 10}}
    %{formula: c_formula, quantity: c_quantity} = elem(element, 1)
    {c_quantity, c_formula}
  end

  def all_base_elements?(parsed_recipe) do
    compound_elements = compound_elements(parsed_recipe)

    res =
      Enum.flat_map(compound_elements, fn comp_element ->
        # {"C",
        #  %{
        #    formula: [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}],
        #    quantity: 1
        #  }}
        {_element, %{formula: compound_composition, quantity: _quantity}} = comp_element
        # "C"
        # [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}]
        # "D"
        # [%{chemical: "A", quantity: "7"}, %{chemical: "C", quantity: "1"}]
        # "E"
        # [%{chemical: "A", quantity: "7"}, %{chemical: "D", quantity: "1"}]

        Enum.map(compound_composition, fn component ->
          chemical = Map.get(component, :chemical)

          Enum.filter(base_elements(parsed_recipe), &match?({^chemical, _}, &1))
          |> Enum.any?()
        end)
      end)

    res
    |> Enum.all?()
  end

  def base_elements(parsed_recipe) do
    parsed_recipe
    |> Enum.filter(&match?({_, %{formula: [%{chemical: "ORE"}]}}, &1))

    # [
    #   {"A", %{formula: [%{chemical: "ORE", quantity: "10"}], quantity: 10}},
    #   {"B", %{formula: [%{chemical: "ORE", quantity: "1"}], quantity: 1}}
    # ]
  end

  def compound_elements(parsed_recipe) do
    (parsed_recipe -- base_elements(parsed_recipe)) -- fuel(parsed_recipe)
    # [
    #   {"C",
    #    %{
    #      formula: [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}],
    #      quantity: 1
    #    }},
    #   {"D",
    #    %{
    #      formula: [%{chemical: "A", quantity: "7"}, %{chemical: "C", quantity: "1"}],
    #      quantity: 1
    #    }},
    #   {"E",
    #    %{
    #      formula: [%{chemical: "A", quantity: "7"}, %{chemical: "D", quantity: "1"}],
    #      quantity: 1
    #    }}
    # ]
  end

  def parse_recipe(recipe) do
    # "  10 ORE => 10 A\n  1 ORE => 1 B\n  7 A, 1 B => 1 C\n"
    # 7 A, 1 B => 1 C
    # %{C: %{quantity: 1, formula: [%{A: 7}, %{B: 1}]}}
    recipe
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    # 7 A, 1 B => 1 C
    [formula, result] =
      line
      |> String.trim()
      |> String.split(" => ")

    [quantity, chemical] =
      result
      |> String.split(" ")

    {chemical, %{quantity: String.to_integer(quantity), formula: parse_formula(formula)}}
    # {"C", %{formula: "7 A, 1 B", quantity: 1}}
  end

  def parse_formula(formula) do
    # "7 A, 1 B"
    formula
    |> String.split(", ")
    |> Enum.map(fn f ->
      [chemical, quantity] =
        String.split(f, " ")
        |> Enum.reverse()

      # [["A", "7"], ["B", "1"]]
      %{chemical: chemical, quantity: quantity}
    end)

    # [%{chemical: "A", quantity: "7"}, %{chemical: "B", quantity: "1"}]
  end
end
