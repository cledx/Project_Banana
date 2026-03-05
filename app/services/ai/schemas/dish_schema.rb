class Ai::Schemas::DishSchema < RubyLLM::Schema
  schema do
    field :recipe_id, type: :string, desc: "The Recipe ID if a recipe was found in the DB, or 'Generate new Recipe' if nothing suitable was found."

    field :recipe_data, type: :object, desc: "If a new recipe needs to be created, provide data for the new recipe." do
      field :cuisine, type: :string, desc: "Cuisine type for the new recipe (required only if generating a new recipe)."
      field :main_ingredient, type: :string, desc: "Main ingredient for the new recipe (required only if generating a new recipe). Ensure the ingredient is in the database."
    end
  end
end