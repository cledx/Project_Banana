class Ai::RecipeGen
    def initialize(cuisine, main_ingredient)
        @cuisine = cuisine
        @main_ingredient = main_ingredient
    end

    def generate_recipe
        @rubyllm = RubyLLM.chat
        .with_tool(SearchIngredientsTool)
        .with_tool(SearchRecipesTool)
        .with_instructions(prompt_gen)
        .with_schema(Ai::Schemas::RecipeSchema.new("RecipeSchema"))
        # Apparently :: is protected by RubyLLM. I'm not sure why. I had to redo the Schema class this way to make it work how I wanted.
        response = @rubyllm.ask("Generate a recipe for #{@main_ingredient} in #{@cuisine} cuisine.")
        parsed_response = response.content
        parsed_response = JSON.parse(parsed_response, symbolize_names: true) if parsed_response.is_a?(String)
        parsed_response = parsed_response.deep_symbolize_keys if parsed_response.respond_to?(:deep_symbolize_keys)
        recipe_attrs = {
            name: parsed_response[:name],
            cuisine: parsed_response[:cuisine],
            cooktime: parsed_response[:cooktime],
            instructions: parsed_response[:instructions],
        }
        recipe = Recipe.create(recipe_attrs)
        parsed_response[:ingredients].each do |ingredient|
            if Ingredient.exists?(name: ingredient[:name])
                recipe.recipe_items.new(ingredient: Ingredient.find_by(name: ingredient[:name]), amount: ingredient[:quantity_value], unit: ingredient[:quantity_unit])
            else
                recipe.recipe_items.new(ingredient: Ingredient.create(name: ingredient[:name]), amount: ingredient[:quantity_value], unit: ingredient[:quantity_unit])
            end
        end
        recipe.save
        recipe
        end

    private

    def prompt_gen
        "You are a professional chef. The user is asking you to create a recipe for a specific cuisine and main ingredient. Check that the recipe you've created is not in the database before creating it. If it is, then create a different recipe."
    end
end
