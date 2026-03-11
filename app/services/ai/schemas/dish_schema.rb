class Ai::Schemas::DishSchema < RubyLLM::Schema
  string :recipe_id, description: "The Recipe ID of the chosen recipe."
end