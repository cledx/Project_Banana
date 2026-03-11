class Ai::WeekGen
  # Deprecated
  # This is no longer needed because the week is generated in the Week model.

  def initialize(user)
    @user = user
  end

  def generate_week(month = (Date.today + 7).beginning_of_week.month,
                    week_start = (Date.today + 7).beginning_of_week, day_templates = nil)
    puts "generate week starting"
    puts "day templates: #{day_templates}"

    puts "*" * 30
    @week = Week.create(user: @user, month: month)
    @rubyllm = RubyLLM.chat
                      .with_instructions(prompt_gen)
                      .with_schema(Ai::Schemas::WeekSchema.new("WeekSchema"))
    response = @rubyllm.ask("The client's previous weeks meals were: \n #{previous_week_meals_text(@user,
                                                                                                   week_start)}. Monday's date is #{week_start}. The user only needs meals for #{day_template_text(day_templates)} Here are the recipes you can select from: \n #{recipe_filter(week_start)}")
    puts "response: #{response}"
    response.content["days"].each do |day|
      new_day = Day.create(week: @week, date: day["date"])
      day["meals"][0].each do |key, value|
        puts "Key: #{key}, Value: #{value.to_i} for day: #{new_day.date}"
        # Find day_template for this day by weekday symbol (e.g., :monday)
        # Then get the portion for the current category key from that day's template
        weekday = new_day.date.to_date.strftime("%A").downcase.to_sym
        portions = day_templates && day_templates[weekday] && day_templates[weekday][key.to_sym]
        puts "portions #{portions}"
        if portions.to_i > 0
          new_dish = Dish.create(day: new_day, portions: portions, recipe_id: value, category: key)
        else
          new_dish = "No meal needed for #{key.capitalize} on #{new_day.date.strftime('%A')}"
        end
        puts "New dish: #{new_dish}"
      end
      new_day.save
    end
    return @week
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
    
    def day_template_text(day_templates)
      return "None." if day_templates.nil?
      day_templates.map do |day, template|
        "#{day.capitalize}: " + template.select { |k, v| v.present? }.keys.map { |key| key.capitalize }.join(", ")
      end.join("\n")
    end

    def recipe_filter(week_start)
      # Return only recipes that do NOT contain any of the tags in @user.disease
      # Exclude recipes that were in the user's previous week's dishes
      disease_tags = Array(@user.disease)
      allergy_tags = Array(@user.allergies)
      previous_recipe_ids = @user.previous_week_dishes(week_start).pluck(:recipe_id).uniq

      favorited_recipe_ids = @user.favorited_recipes
      recipes = Recipe
        .where.not(id: previous_recipe_ids)
        .where(
          disease_tags.reject(&:blank?).map { |tag| "tags NOT LIKE ?" }.join(' AND '),
          *disease_tags.reject(&:blank?).map { |tag| "%#{tag}%" }
        )
        .where(
          allergy_tags.reject(&:blank?).map { |tag| "tags NOT LIKE ?" }.join(' AND '),
          *allergy_tags.reject(&:blank?).map { |tag| "%#{tag}%" }
        )
      recipes_text = recipes.map do |recipe|
        favoritized = favorited_recipe_ids.include?(recipe.id) ? "(Favorited Recipe)" : ""
        "#{favoritized}#{recipe.name} - ID: #{recipe.id}"
      end.join("\n")
      return recipes_text
    end
    recipes_text = recipes_filter_disease.map do |recipe|
      favoritized = @user.favorited?(recipe) ? "(Favorited Recipe)" : ""
      "(#{favoritized})#{recipe.name} - ID: #{recipe.id}"
    end.join("\n")
    return recipes_text
  end

  def day_template_text(day_templates)
    return "None." if day_templates.nil?

    day_templates.map do |day, template|
      "#{day.capitalize}: " + template.select { |k, v| v.present? }.keys.map { |key| key.capitalize }.join(", ")
    end.join("\n")
  end
end
