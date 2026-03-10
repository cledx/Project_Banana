class Ai::WeekGen
    # Deprecated
    # This is no longer needed because the week is generated in the Week model.
    
    def initialize(user)
      @user = user
    end

    def generate_week(month = (Date.today + 7).beginning_of_week.month, week_start = (Date.today + 7).beginning_of_week)
        @week = Week.create(user: @user, month: month)
        @rubyllm = RubyLLM.chat
        .with_instructions(prompt_gen)
        .with_schema(Ai::Schemas::WeekSchema.new("WeekSchema"))
        response = @rubyllm.ask("The client's previous weeks meals were: \n #{previous_week_meals_text(@user, week_start)}. Monday's date is #{week_start}. Here are the recipes you can select from: \n #{recipe_filter(week_start)}")
        response.content["days"].each do |day|
            new_day = Day.create(week: @week, date: day["date"])
            day["meals"][0].each do |key, value|
                puts "Key: #{key}, Value: #{value.to_i} for day: #{new_day.date}"
                new_dish = Dish.create(day: new_day, portions: 2, recipe_id: value, category: key)
                puts "New dish: #{new_dish.inspect}"
            end
            new_day.save
        end
        @week
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
      You need to plan a few meals for them to cook in advance to feed them for the week. Select only 3 different recipes maximum for the whole week, and spread them out between the days.
      Select from the following recipes and pick the best ones for the user.
      PROMPT
    end

    def recipe_filter(week_start)
      # Return only recipes that do NOT contain any of the tags in @user.disease
      # Exclude recipes that were in the user's previous week's dishes
      previous_recipe_ids = @user.previous_week_dishes(week_start).pluck(:recipe_id).uniq
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

