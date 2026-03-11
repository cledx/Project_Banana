# ============================================================
# seeds.rb
# ============================================================

puts "Cleaning database..."
puts "Deleting Favorites..."
Favorite.destroy_all
puts "Deleting Dishes..."
Dish.destroy_all
puts "Deleting Shopping Items..."
ShoppingItem.destroy_all
puts "Deleting Days..."
Day.destroy_all
puts "Deleting Weeks..."
Week.destroy_all
puts "Deleting Day Templates..."
DayTemplate.destroy_all
puts "Deleting Recipe Items..."
RecipeItem.destroy_all
puts "Deleting Recipes..."
Recipe.destroy_all
puts "Deleting Ingredients..."
Ingredient.destroy_all
puts "Deleting Users..."
User.destroy_all


# ============================================================
# REFERENCE DATA
# ============================================================

USERS_DATA = [
  ["koji@lewagon.com",      "Koji the Wise"],
  ["katherine@lewagon.com", "Katherine the Nicest"],
  ["glau@lewagon.com",      "Glau the Nice"],
  ["karlos@lewagon.com",    "Charlos the kraykray"]
]

ALL_ALLERGIES = ["peanuts", "tree nuts", "shellfish", "dairy", "gluten", "soy", "eggs", "fish"]

# ALL_INGREDIENTS = [
#   "chicken breast", "salmon", "ground beef", "tofu", "shrimp", "pasta", "rice",
#   "potatoes", "tomatoes", "onion", "garlic", "spinach", "mushrooms", "bell pepper",
#   "zucchini", "lemon", "olive oil", "butter", "heavy cream", "parmesan",
#   "mozzarella", "cheddar", "bacon", "sausage", "broccoli", "carrots", "celery",
#   "ginger", "soy sauce", "coconut milk", "chickpeas", "lentils", "black beans",
#   "corn", "avocado", "lime", "cilantro", "basil", "thyme", "rosemary"
# ]

# ALL_CUISINES = ["French", "Italian", "Japanese", "Mexican", "Indian", "Thai",
#                 "Chinese", "Mediterranean", "American", "Spanish"]

ALL_DISEASES = [nil, "gluten", "soy", "dairy"]

UNITS = ["g", "ml", "tbsp", "tsp", "cup", "oz", "piece", "clove", "slice"]

CATEGORIES = ["breakfast", "lunch", "dinner"]

RECIPE_NAMES = [
  "Rustic Tomato Pasta", "Garlic Butter Salmon", "Spicy Chicken Stir-fry",
  "Mushroom Risotto", "Beef Tacos", "Thai Green Curry", "Lemon Herb Chicken",
  "Vegetable Fried Rice", "Classic French Omelette", "Shrimp Scampi",
  "Margherita Pizza", "Caesar Salad", "Beef Bourguignon", "Pad Thai",
  "Chicken Tikka Masala", "Spaghetti Carbonara", "Greek Salad", "Miso Soup"
  "Ratatouille", "Avocado Toast", "Shakshuka", "Lentil Soup", "Pesto Gnocchi",
  "Teriyaki Salmon", "Black Bean Tacos", "Butternut Squash Soup",
  "Chicken Parmigiana", "Tofu Scramble", "Prawn Linguine", "Niçoise Salad"
]

LOREM_INSTRUCTIONS = "1. Preheat the oven to 200°C (400°F). Line a baking tray with parchment paper.
2. In a large bowl, toss the chopped vegetables with olive oil, salt, and pepper until evenly coated.
3. Spread the vegetables in a single layer on the prepared baking tray.
4. Roast in the oven for 20–25 minutes, stirring once halfway through, until the vegetables are tender and lightly browned.
5. While the vegetables roast, cook the quinoa according to the package instructions, then fluff with a fork and set aside.
6. In a small bowl, whisk together the lemon juice, extra-virgin olive oil, minced garlic, and a pinch of salt to make the dressing.
7. In a large serving bowl, combine the cooked quinoa, roasted vegetables, and chopped fresh herbs.
8. Pour the dressing over the mixture and gently toss until everything is well coated.
9. Taste and adjust seasoning with additional salt, pepper, or lemon juice if needed.
10. Serve warm or at room temperature, optionally topped with crumbled feta or toasted nuts.
"

# ============================================================
# INGREDIENTS (create all upfront so recipes can reference them)
# ============================================================

# puts "Creating ingredients..."
# ingredient_records = ALL_INGREDIENTS.map do |name|
#   Ingredient.create!(name: name)
# end

# # Helper: pick random ingredients as records
# def random_ingredients(ingredient_records, min, max)
#   ingredient_records.sample(rand(min..max))
# end

# ============================================================
# RECIPES (create a pool so dishes can reference them)
# ========================================================
#
# We've already seeded the recipes into the database.
# Only run this if you want to recreate the recipes.

require "json"

puts "Creating recipes..."
filepath = Rails.root.join("db", "data", "recipesV3.json")
serialized_data = File.read(filepath)
recipes_data = JSON.parse(serialized_data)
recipes = recipes_data["data"]

recipes.each do |recipe_hash|
  name         = recipe_hash["name"]
  cooktime     = recipe_hash["cook_time"]   # minutes
  preptime     = recipe_hash["prep_time"]   # minutes
  instructions = recipe_hash["instructions"]
  cuisine      = recipe_hash["cuisine"]
  tags         = recipe_hash["tags"] || []

  recipe = Recipe.create!(
    name: name,
    cooktime: cooktime,
    preptime: preptime,
    instructions: instructions,
    cuisine: cuisine,
    tags: tags
  )

  ingredients = recipe_hash["ingredients"]

  ingredients.each do |ingredient_hash|
    ingredient_name = ingredient_hash["name"].downcase
    ingredient = Ingredient.find_by(name: ingredient_name)
    ingredient ||= Ingredient.create!(name: ingredient_name)

    raw_amount = ingredient_hash["amount"].to_s

    # Extract numeric part; default to 1 if missing
    parsed_amount = raw_amount.gsub(/[^0-9.]+/, "").strip
    amount = parsed_amount.empty? ? 1 : parsed_amount.to_f

    # Extract unit part; ensure it is never blank for validation
    unit = raw_amount.gsub(/[0-9.]+/, "").strip
    unit = ingredient_hash["unit"] if unit.blank?

    RecipeItem.create!(
      recipe: recipe,
      ingredient: ingredient,
      amount: amount,
      unit: unit
      modifier: ingredient_hash["modifier"] || ""
    )
  end
end


# ============================================================
# USERS
# ============================================================

puts "Creating users..."
# 4.times do |i|
#   user = User.create!(
#     email:                  USERS_DATA[i][0],
#     username:               USERS_DATA[i][1],
#     password:               "123456",
#     allergies:              ALL_ALLERGIES.sample(rand(0..2)),
#     preferred_ingredients:  ALL_INGREDIENTS.sample(rand(2..5)),
#     undesireable_ingredients: ALL_INGREDIENTS.sample(rand(2..5)),
#     preferred_cuisines:     ALL_CUISINES.sample(rand(1..2)),
#     disease:                [ALL_DISEASES.compact.sample, nil].sample(1).tap { |a| a.compact! }
#   )
# end

# ALL_INGREDIENTS = Ingredient.all.pluck(:name).map { |name| name.downcase }
ALL_INGREDIENTS = Ingredient.all.pluck(:name).map(&:downcase)
ALL_CUISINES = Recipe.all.pluck(:cuisine).map(&:capitalize)

  user = User.create!(
    email:                  "jeff@business.com",
    username:               "Jeff Business",
    password:               "123456",
    allergies:              nil,
    preferred_ingredients:  ALL_INGREDIENTS.sample(rand(2..5)),
    undesireable_ingredients: ALL_INGREDIENTS.sample(rand(2..5)),
    preferred_cuisines:     "Italian",
    disease:                "diabetes"
  )
  puts "  Created user: #{user.username}"

  # ----------------------------------------------------------
  # DAY TEMPLATE
  # ----------------------------------------------------------
  ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"].each do |day_name|
    DayTemplate.create!(
      user: user,
      day_name: day_name,
      breakfast: 0,
      lunch:     2,
      dinner:    2
    )
  end

  # ----------------------------------------------------------
  # WEEK → 7 DAYS → DISHES
  # ----------------------------------------------------------
  # week = Week.create!(
  #   user: user,
  #   month: rand(1..12)
  # )

  # # Track ingredients needed across the week for shopping list
  # ingredient_totals = Hash.new { |h, k| h[k] = { amount: 0.0, unit: nil } }

  # 7.times do |day_index|
  #   day = Day.create!(
  #     week: week,
  #     date: DateTime.now.beginning_of_week + day_index.days
  #   )

  #   rand(1..3).times do
  #     recipe = Recipe.all.sample
  #     dish = Dish.create!(
  #       day: day,
  #       recipe: recipe,
  #       portions: rand(1..3),
  #       category: CATEGORIES.sample
  #     )

  #     # Accumulate shopping totals
  #     recipe.recipe_items.each do |ri|
  #       key = [ri.ingredient_id, ri.unit]
  #       ingredient_totals[key][:amount] += ri.amount * dish.portions
  #       ingredient_totals[key][:unit]    = ri.unit
  #       ingredient_totals[key][:ingredient_id] = ri.ingredient_id
  #     end
  #   end
  # end

  # ============================================================
  # CURRENT WEEK
  # ============================================================
  week_start = Date.today.beginning_of_week(:monday)

  # Create a new week for the user and generate dinner dishes using AI::DishGen for each day
  # Generate a dinner dish for 2 people using AI::DishGen
  Ai::WeekGen.new(user).generate_week(week_start.month, week_start)

  # [week_start].each do |start_date|
  #   week = Week.create!(
  #     user: user,
  #     month: start_date.month
  #   )
  #
  #   # Track ingredients needed across the week for shopping list
  #   ingredient_totals = Hash.new { |h, k| h[k] = { amount: 0.0, unit: nil } }
  #
  #   7.times do |day_index|
  #     day = Day.create!(
  #       week: week,
  #       date: start_date + day_index.days
  #     )
  #
  #     3.times do |i|
  #       recipe = Recipe.all.sample
  #       dish = Dish.create!(
  #         day: day,
  #         recipe: recipe,
  #         portions: 2,
  #         category: ["breakfast", "lunch", "dinner"][i]
  #       )
  #
  #       recipe.recipe_items.each do |ri|
  #         key = [ri.ingredient_id, ri.unit]
  #         ingredient_totals[key][:amount] += ri.amount * dish.portions
  #         ingredient_totals[key][:unit]    = ri.unit
  #         ingredient_totals[key][:ingredient_id] = ri.ingredient_id
  #       end
  #     end
  #   end
  # end

  # ============================================================
  # NEXT WEEK
  # ============================================================


  # Ai::WeekGen.new(user).generate_week


  # ----------------------------------------------------------
  # SHOPPING ITEMS (aggregated from week's dishes)
  # ----------------------------------------------------------
  # ingredient_totals.each do |(_ingredient_id, _unit), data|
  #   ShoppingItem.create!(
  #     week: week,
  #     ingredient_id: data[:ingredient_id],
  #     total: data[:amount].round(2),
  #     unit: data[:unit],
  #     purchased: false
  #   )
  # end

  # ----------------------------------------------------------
  # FAVORITES (1–5 random recipes)
  # ----------------------------------------------------------
  Recipe.all.sample(4).each do |recipe|
    Favorite.create!(user: user, recipe: recipe)
  end

  puts "✅ Seed complete!"

