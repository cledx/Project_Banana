class Ai::Schemas::DishSchema < RubyLLM::Schema
  string :recipe_id, description: "The Recipe ID if a recipe was found in the DB, or 'Generate new Recipe' if nothing suitable was found."

  object :recipe_data, description: "If a new recipe needs to be created, provide data for the new recipe." do
    string :cuisine, description: "Cuisine type for the new recipe (required only if generating a new recipe)."
    string :main_ingredient, description: "Main ingredient for the new recipe (required only if generating a new recipe). Ensure the ingredient is in the database."
  end
end