class Ai::DishGen

  def initialize(day, portions, category, user)
      @day = day
      @portions = portions
      @category = category
      @user = user
  end

    def generate_dish
        @rubyllm = RubyLLM.chat
        .with_instructions(prompt_gen)
        .with_schema(Ai::Schemas::DishSchema.new("DishSchema"))
        # Generate the previous week's meals text.
        previous_meals = previous_week_meals_text(@day.week.user, @day.date)
        # Generate the current week's meals text.
        current_week_meals = @day.week.dishes.map { |dish| "#{dish.day.date.strftime('%A')}: #{dish.category} - #{dish.recipe.name}"}.join("\n")
        # Generate the response from the AI.
        response = @rubyllm.ask("The client's previous weeks meals were: \n #{previous_meals}. This weeks meals so far are: \n #{current_week_meals}. You need to select a meal for #{@day.date.strftime('%A')} for #{@category}. Here are the recipes you can select from: \n #{recipe_filter}")
        # If the recipe ID is "Generate new Recipe", then create a new recipe.
        dish = Dish.create(day: @day, recipe_id: response.content["recipe_id"], category: @category, portions: @portions)
        return dish
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
      prompt = <<-PROMPT
      You are a meal cooridnator. 
      The user is a busy person who need help with planning their meals to prep for the week. 
      You need to plan a few meals for them to cook in advance to feed them for the week. Use a recipe for no more than three days in a row.
      Select from the following recipes and pick the best ones for the user.
      PROMPT
    end

    def recipe_filter
      # Return only recipes that do NOT contain any of the tags in @user.disease
      # Exclude recipes that were in the user's previous week's dishes
      previous_recipe_ids = @user.previous_week_dishes(@day.date).pluck(:recipe_id).uniq
      recipes_filter_recent = Recipe.where.not(id: previous_recipe_ids)
      recipes_filter_disease = recipes_filter_recent.select do |recipe|
        Array(@user.disease).none? { |tag| recipe.tags.include?(tag) }
      end
      recipes_text = recipes_filter_disease.map do |recipe|
        favoritized = @user.favorited?(recipe) ? "(Favorited Recipe)" : ""
        "(#{favoritized})#{recipe.name} - ID: #{recipe.id}"
      end.join("\n")
      return recipes_text
    end

end
    