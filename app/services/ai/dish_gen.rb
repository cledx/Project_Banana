class Ai::DishGen

  def initialize(dish_id)
    @dish = Dish.find(dish_id)
    @day = @dish.day
    @portions = @dish.portions
    @category = @dish.category
    @user = @dish.day.week.user
    @recipe = @dish.recipe
  end

    def generate_dish
        @rubyllm = RubyLLM.chat
        .with_instructions(prompt_gen)
        .with_schema(Ai::Schemas::DishSchema.new("DishSchema"))
        # Generate the current week's meals text.
        current_week_meals = @day.week.dishes.map { |dish| "#{dish.day.date.strftime('%A')}: #{dish.category} - #{dish.recipe.name}"}.join("\n")
        # Generate the response from the AI.
        response = @rubyllm.ask("This weeks meals so far are: \n #{current_week_meals}. You need to select a meal for #{@day.date.strftime('%A')} for #{@category}. Here are the recipes you can select from: \n #{recipe_filter}")
        # If the recipe ID is "Generate new Recipe", then create a new recipe.
        puts "Updating dish with recipe ID: #{response.content["recipe_id"]}"
        @dish.update(recipe_id: response.content["recipe_id"])
        puts "Dish updated: #{@dish.inspect}"
        return @dish
    end

    private

    def prompt_gen
      prompt = <<-PROMPT
      You are a meal cooridnator. 
      The user is a busy person who need help with planning their meals to prep for the week. 
      The user wants to replace the current recipe with a new one. Here is the current recipe: #{@recipe.name}
      PROMPT
    end

    def recipe_filter(week_start = @day.date.beginning_of_week)
      # Return only recipes that do NOT contain any of the tags in @user.disease
      # Exclude recipes that were in the user's previous week's dishes
      disease_tags = Array(@user.disease).reject(&:blank?)
      allergy_tags = Array(@user.allergies).reject(&:blank?)
      previous_recipe_ids = @user.previous_week_dishes(week_start).pluck(:recipe_id).uniq

      # Also exclude recipes in the current week
      current_week_recipe_ids = @user.dishes.includes(:day).where(days: { week_id: @day.week.id }).pluck(:recipe_id).uniq

      recipes = Recipe.where.not(id: previous_recipe_ids + current_week_recipe_ids)

      # tags is a string array; use unnest + LIKE so we don't use string ops on the array
      disease_tags.each do |tag|
        pattern = "%#{Recipe.sanitize_sql_like(tag)}%"
        recipes = recipes.where(
          "NOT EXISTS (SELECT 1 FROM unnest(COALESCE(recipes.tags, ARRAY[]::text[])) AS t WHERE t LIKE ?)",
          pattern
        )
      end
      allergy_tags.each do |tag|
        pattern = "%#{Recipe.sanitize_sql_like(tag)}%"
        recipes = recipes.where(
          "NOT EXISTS (SELECT 1 FROM unnest(COALESCE(recipes.tags, ARRAY[]::text[])) AS t WHERE t LIKE ?)",
          pattern
        )
      end

      favorited_recipe_ids = @user.favorited_recipes
      recipes_text = recipes.map do |recipe|
        favoritized = favorited_recipe_ids.include?(recipe.id) ? "(Favorited Recipe)" : ""
        "#{favoritized}#{recipe.name} - ID: #{recipe.id}"
      end.join("\n")
      return recipes_text
    end

end
    