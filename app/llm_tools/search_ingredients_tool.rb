# This tool will be used when the LLM is making a recipe and it needs to check if the ingredients are already in the database.
# If the ingredients are not in the database, the LLM will need to make a new recipe with different ingredients.

class SearchIngredientsTool < RubyLLM::Tool
    description "Searches the database for ingredients"
    param :ingredients, type: :array, desc: "The ingredients to search for"

    def execute(ingredients:)
    requested = Array(ingredients).map(&:to_s)
    return "No ingredients to search for." if requested.empty?

    conditions = requested.map { "name ILIKE ?" }.join(" OR ")
    values = requested.map { |name| "%#{name}%" }
    found_ingredients = Ingredient.where(conditions, *values)

    if found_ingredients.any?
      found_ingredients.map do |ingredient|
        {
          id: ingredient.id,
          name: ingredient.name
        }
      end.to_json
    else
      "Missing ingredients: #{requested.join(', ')}. Please make a new recipe without these ingredients."
    end
  end
end