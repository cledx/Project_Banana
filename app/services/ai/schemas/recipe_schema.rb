class Ai::Schemas::RecipeSchema < RubyLLM::Schema
  string :name, description: "The name of the recipe"
  string :cuisine, description: "Cuisine type (e.g., Italian, Chinese, Mexican)"
  number :cooktime, description: "Total time to prepare and cook the recipe in seconds"
  string :instructions, description: "Full cooking instructions as text. Use Markdown format for the instructions."

  array :ingredients, description: "The list of ingredients for the recipe" do
    object do
      string :name, description: "Name of the ingredient"
      string :quantity_value, description: "Numeric quantity (e.g., 2, 1.5, 1/2)"
      string :quantity_unit, description: "Unit of measure (e.g., cups, tbsp, kg, g, ml, pinch)"
    end
  end
end