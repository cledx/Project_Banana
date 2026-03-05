class Ai::Schemas::RecipeSchema < RubyLLM::Schema
  schema do
    field :name,         type: :string,  desc: "The name of the recipe"
    field :cuisine,      type: :string,  desc: "Cuisine type (e.g., Italian, Chinese, Mexican)"
    field :cooktime,     type: :integer, desc: "Cooking time in minutes"
    field :instructions, type: :string,  desc: "Full cooking instructions as text. Use numbered steps separated by new lines."

    field :ingredients, type: :array, desc: "The list of ingredients for the recipe" do
      item type: :object do
        field :name,            type: :string, desc: "Name of the ingredient"
        field :quantity_value,  type: :string, desc: "Numeric quantity (e.g., 2, 1.5, 1/2)"
        field :quantity_unit,   type: :string, desc: "Unit of measure (e.g., cups, tbsp, kg, g, ml, pinch)"
      end
    end
  end
end