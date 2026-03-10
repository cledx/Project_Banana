class Ai::Schemas::DishSchema < RubyLLM::Schema
  string :recipe_id, description: "The Recipe ID if a recipe was found in the DB, or 'Generate new Recipe' if nothing suitable was found."
end