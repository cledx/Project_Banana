class Ai::RecipeGenerator
    def initialize(cuisine, main_ingredient)
        @cuisine = cuisine
        @main_ingredient = main_ingredient
    end

    def generate_recipe
        @rubyllm = RubyLLM.new.chat
        .with_tool(SearchIngredientsTool, SearchRecipesTool)
        .with_instruction(prompt_gen)
        .with_schema(Ai::Schemas::RecipeSchema)
        response = @rubyllm.ask("Generate a recipe for #{@main_ingredient} in #{@cuisine} cuisine.")
        parsed_response = JSON.parse(response, symbolize_names: true)
        recipe_attrs = {
            name: parsed_response[:name],
            cuisine: parsed_response[:cuisine],
            cooktime: parsed_response[:cooktime],
            instructions: parsed_response[:instructions],
        }
        recipe = Recipe.new(recipe_attrs)
        parsed_response[:ingredients].each do |ingredient|
            if Ingredient.exists?(name: ingredient[:name])
                recipe.recipe_items.create(ingredient: Ingredient.find_by(name: ingredient[:name]), amount: ingredient[:quantity_value], unit: ingredient[:quantity_unit])
            else
                recipe.recipe_items.create(ingredient: Ingredient.create(name: ingredient[:name]), amount: ingredient[:quantity_value], unit: ingredient[:quantity_unit])
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