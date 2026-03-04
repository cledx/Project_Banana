class Ai::DishGenerator
    # This one might not be needed, but I'll keep it here for now.
    def initialize(day, dish_num, meal_name)
      @day = day
      @dish_num = dish_num
      @meal_name = meal_name
    end

    def generate_dish
        @rubyllm = RubyLLM.new
        @rubyllm
        @rubyllm.chat.with_tool(SearchIngredientsTool, SearchRecipesTool)
        response = @rubyllm.ask("Generate a recipe for #{@meal_name} with the folloing number of portions: #{@dish_num}")
        response.tools.each do |tool|
            if tool.name == "SearchIngredientsTool"
                tool.execute(ingredients: tool.params[:ingredients])
            elsif tool.name == "SearchRecipesTool"
                tool.execute(main_ingredient: tool.params[:main_ingredient], cuisine: tool.params[:cuisine])
            end
        end
    end

    private

    def prompt_gen
      "You are a personal private meal cooridnator. Your client is a busy professional who need help with planning their meals for the week. You are given a history of what is planned for the week so far and you need to choose a recipe that is not already in the plan. Keep in mind the client's dietary restrictions and preferences. If there are no recipes that match in the database, then you will need to create a new recipe."
    end

end
    