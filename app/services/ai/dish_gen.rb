class Ai::DishGen

  def initialize(day, portions, meal_name)
      @day = day
      @portions = portions
      @meal_name = meal_name
  end

    def generate_dish
        @rubyllm = RubyLLM.chat
        .with_tool(SearchIngredientsTool)
        .with_tool(SearchRecipesTool)
        .with_instructions(prompt_gen)
        .with_schema(Ai::Schemas::DishSchema.new("DishSchema"))
        # Generate the previous week's meals text.
        previous_meals = previous_week_meals_text(@day.week.user, @day.date)
        # Generate the current week's meals text.
        current_week_meals = @day.week.dishes.map { |dish| "#{dish.day.date.strftime('%A')}: #{dish.category}: #{dish.recipe.name}"}.join("\n")
        # Generate the response from the AI.
        response = @rubyllm.ask("The client's previous weeks meals were: #{previous_meals}. You need to generate a meal for #{@day.date.strftime('%A')} for #{@meal_name}. This weeks meals so far are: #{current_week_meals}. Generate a new dish not already in the plan and avoid meals from last week.")
        # If the recipe ID is "Generate new Recipe", then create a new recipe.
        if response.content["recipe_id"] == "Generate new Recipe"
          new_recipe = Ai::RecipeGen.new(response.content["recipe_data"]["cuisine"], response.content["recipe_data"]["main_ingredient"]).generate_recipe
          dish = Dish.create(day: @day, recipe_id: new_recipe.id, category: @meal_name, portions: @portions)
        else
          dish = Dish.create(day: @day, recipe_id: response.content["recipe_id"], category: @meal_name, portions: @portions)
        end
        dish
    end

    private

    def previous_week_meals_text(user, reference_date)
      dishes = user.previous_week_dishes(reference_date)
      return "None." if dishes.empty?
      # Group the dishes by date and sort them by date.
      dishes
        .group_by { |d| d.day.date.to_date }
        .sort_by { |date, _| date }
        .map do |date, day_dishes|
          meals = day_dishes.sort_by(&:category).map { |d| "#{d.category}: #{d.recipe.name}" }.join("; ")
          "#{date.strftime('%A')}: #{meals}"
        end
        .join("\n")
    end

    def prompt_gen
      "You are a personal private meal cooridnator. Your client is a busy professional who need help with planning their meals for the week. You are given a history of what is planned for the week so far and you need to choose a recipe that is not already in the plan. Keep in mind the client's dietary restrictions and preferences. If there are no recipes that match in the database, then you will need to create a new recipe. \n The Client's dietary restrictions are: #{@day.week.user.disease} and #{@day.week.user.allergies}. \n The Client's preferences are: #{@day.week.user.preferred_cuisines} and #{@day.week.user.preferred_ingredients}."
    end

end
    