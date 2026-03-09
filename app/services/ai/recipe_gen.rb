class Ai::RecipeGen
    def initialize(cuisine, main_ingredient)
        @cuisine = cuisine
        @main_ingredient = main_ingredient
    end

    def generate_recipe
        @rubyllm = RubyLLM.chat
        .with_tool(SearchIngredientsTool)
        .with_instructions(prompt_gen)
        .with_schema(Ai::Schemas::RecipeSchema.new("RecipeSchema"))
        # Apparently :: is protected by RubyLLM. I'm not sure why. I had to redo the Schema class this way to make it work how I wanted.
        response = @rubyllm.ask("Generate a recipe for #{@main_ingredient} in #{@cuisine} cuisine.")
        recipe_attrs = {
            name: response.content["name"],
            cuisine: response.content["cuisine"],
            cooktime: response.content["cooktime"],
            instructions: response.content["instructions"],
        }
        recipe = Recipe.create(recipe_attrs)
        response.content["ingredients"].each do |ingredient|
            if Ingredient.exists?(name: ingredient["name"])
                recipe.recipe_items.new(ingredient: Ingredient.find_by(name: ingredient["name"]), amount: ingredient["quantity_value"], unit: ingredient["quantity_unit"])
            else
                recipe.recipe_items.new(ingredient: Ingredient.create(name: ingredient["name"]), amount: ingredient["quantity_value"], unit: ingredient["quantity_unit"])
            end
        end
        recipe.save
        recipe
        end

    private

    def prompt_gen
        "You are a professional chef. The user is asking you to create a recipe for a specific cuisine and main ingredient."
    end
end
