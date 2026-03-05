# This tool is used to search the database for recipes.
# The LLM can use this tool to see if any recipes already in the DB match the cuisine and ingredients it desires to avoid creating duplicate recipes.

class SearchRecipesTool < RubyLLM::Tool
    description "Searches the database for recipes"
    param :main_ingredient, type: :string, desc: "The main ingredient to search for"
    param :cuisine, type: :string, desc: "The cuisine to search for"

    def execute(main_ingredient:, cuisine:)
    recipes = Recipe.joins(:ingredients)
                    .where('ingredients.name ILIKE ?', "%#{main_ingredient}%")
                    .where('recipes.cuisine ILIKE ?', "%#{cuisine}%")
                    .distinct

    if recipes.any?
      recipes.map do |recipe|
        {
          id: recipe.id,
          name: recipe.name,
          cuisine: recipe.cuisine
        }
      end.to_json
    else
      "No recipe found with ingredient '#{main_ingredient}' and cuisine '#{cuisine}'."
    end
  end
end