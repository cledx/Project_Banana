class Ai::WeekGen
  # Deprecated
  # This is no longer needed because the week is generated in the Week model.

  def initialize(user)
    @user = user
  end

  def generate_week(attributes)
    puts "*" * 30
    puts "attributes in week gen: #{attributes}"
    puts "*" * 30
    day_templates = attributes["day_templates"]
    week_id = attributes["week_id"]
    puts "generate week starting"
    puts "day templates: #{day_templates}"
    puts "*" * 30
    @week = Week.find(week_id)
    month = @week.month
    week_start = @week.days.first.date.beginning_of_week
    @rubyllm = RubyLLM.chat.with_instructions(prompt_gen).with_schema(Ai::Schemas::WeekSchema.new("WeekSchema"))
    response = @rubyllm.ask("The client's previous weeks meals were: \n #{previous_week_meals_text(@user, week_start)}. Monday's date is #{week_start}. The user only needs meals for #{day_template_text(day_templates)} Here are the recipes you can select from: \n #{recipe_filter(week_start)}")
    response.content["days"].each do |day|
      puts day

      # Reuse or create the day for this date instead of always creating a new one.
      day_date = Date.parse(day["date"].to_s)
      new_day = @week.days.find_or_create_by!(date: day_date)

      day["meals"][0].each do |key, value|
        puts "v" * 30
        puts "Key: #{key}, Value: #{value.to_i} for day: #{new_day.date}"
        # Find day_template for this day by weekday symbol (e.g., :monday)
        # Then get the portion for the current category key from that day's template
        weekday = new_day.date.to_date.strftime("%A").downcase.to_sym
        portions = day_templates && day_templates[weekday] && day_templates[weekday][key.to_sym]
        puts "portions #{portions}"
        if portions.to_i > 0
          new_dish = Dish.create(day: new_day, portions: portions, recipe_id: value, category: key)
          puts "New dish: #{new_dish.inspect} for #{new_dish.day.date} for week_id: #{new_dish.day.week.id}"
        else
          puts "No meal needed for #{key.capitalize} on #{new_day.date.strftime('%A')}"
        end
        
        puts "^" * 30
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
    return prompt
  end

  def recipe_filter(week_start)
    # Return only recipes that do NOT contain any of the tags in @user.disease
    # Exclude recipes that were in the user's previous week's dishes
    disease_tags = Array(@user.disease).reject(&:blank?)
    allergy_tags = Array(@user.allergies).reject(&:blank?)
    previous_recipe_ids = @user.previous_week_dishes(week_start).pluck(:recipe_id).uniq

    recipes = Recipe.where.not(id: previous_recipe_ids)

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

  def day_template_text(day_templates)
    return "None." if day_templates.nil?

    day_templates.map do |day, template|
      "#{day.capitalize}: " + template.select { |k, v| v.present? }.keys.map { |key| key.capitalize }.join(", ")
    end.join("\n")
  end
end
