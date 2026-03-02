# ============================================================
# seeds.rb
# ============================================================

puts "Cleaning database..."
ShoppingItem.destroy_all
Favorite.destroy_all
Dish.destroy_all
Day.destroy_all
Week.destroy_all
DayTemplate.destroy_all
RecipeItem.destroy_all
Recipe.destroy_all
Ingredient.destroy_all
User.destroy_all

# ============================================================
# REFERENCE DATA
# ============================================================

USERS_DATA = [
  ["koji@lewagon.com",      "Koji the Quiet"],
  ["katherine@lewagon.com", "Katherine the Stinky"],
  ["glau@lewagon.com",      "Glau the Nice"],
  ["carlos@lewagon.com",    "Carlos the Magnificent"]
]

ALL_ALLERGIES = ["peanuts", "tree nuts", "shellfish", "dairy", "gluten", "soy", "eggs", "fish"]

ALL_INGREDIENTS = [
  "chicken breast", "salmon", "ground beef", "tofu", "shrimp", "pasta", "rice",
  "potatoes", "tomatoes", "onion", "garlic", "spinach", "mushrooms", "bell pepper",
  "zucchini", "lemon", "olive oil", "butter", "heavy cream", "parmesan",
  "mozzarella", "cheddar", "bacon", "sausage", "broccoli", "carrots", "celery",
  "ginger", "soy sauce", "coconut milk", "chickpeas", "lentils", "black beans",
  "corn", "avocado", "lime", "cilantro", "basil", "thyme", "rosemary"
]

ALL_CUISINES = ["French", "Italian", "Japanese", "Mexican", "Indian", "Thai",
                "Chinese", "Mediterranean", "American", "Spanish"]

ALL_DISEASES = [nil, "diabetes", "hypertension", "celiac disease", "IBS", "gout"]

UNITS = ["g", "ml", "tbsp", "tsp", "cup", "oz", "piece", "clove", "slice"]

CATEGORIES = ["breakfast", "lunch", "dinner"]

RECIPE_NAMES = [
  "Rustic Tomato Pasta", "Garlic Butter Salmon", "Spicy Chicken Stir-fry",
  "Mushroom Risotto", "Beef Tacos", "Thai Green Curry", "Lemon Herb Chicken",
  "Vegetable Fried Rice", "Classic French Omelette", "Shrimp Scampi",
  "Margherita Pizza", "Caesar Salad", "Beef Bourguignon", "Pad Thai",
  "Chicken Tikka Masala", "Spaghetti Carbonara", "Greek Salad", "Miso Soup",
  "Ratatouille", "Avocado Toast", "Shakshuka", "Lentil Soup", "Pesto Gnocchi",
  "Teriyaki Salmon", "Black Bean Tacos", "Butternut Squash Soup",
  "Chicken Parmigiana", "Tofu Scramble", "Prawn Linguine", "Niçoise Salad"
]

LOREM_INSTRUCTIONS = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Preheat pan over medium heat. Add oil and let it shimmer. Combine ingredients as listed and cook until golden. Season with salt and pepper to taste. Plate beautifully and serve immediately."

# ============================================================
# INGREDIENTS (create all upfront so recipes can reference them)
# ============================================================

puts "Creating ingredients..."
ingredient_records = ALL_INGREDIENTS.map do |name|
  Ingredient.create!(name: name)
end

# Helper: pick random ingredients as records
def random_ingredients(ingredient_records, min, max)
  ingredient_records.sample(rand(min..max))
end

# ============================================================
# RECIPES (create a pool so dishes can reference them)
# ============================================================

puts "Creating recipes..."
recipe_records = RECIPE_NAMES.map.with_index do |name, i|
  recipe = Recipe.create!(
    name: name,
    cooktime: [600, 900, 1200, 1800, 2400, 3000].sample,
    cuisine: ALL_CUISINES.sample,
    instructions: LOREM_INSTRUCTIONS
  )

  # Each recipe gets 1 RecipeItem with a random ingredient
  ingredient = ingredient_records.sample
  RecipeItem.create!(
    recipe: recipe,
    ingredient: ingredient,
    amount: (rand(1..500).to_f / 10.0).round(1),
    unit: UNITS.sample
  )

  recipe
end

# ============================================================
# USERS
# ============================================================

puts "Creating users..."
4.times do |i|
  user = User.create!(
    email:                  USERS_DATA[i][0],
    username:               USERS_DATA[i][1],
    password:               "123456",
    allergies:              ALL_ALLERGIES.sample(rand(0..2)),
    preferred_ingredients:  ALL_INGREDIENTS.sample(rand(2..5)),
    undesireable_ingredients: ALL_INGREDIENTS.sample(rand(2..5)),
    preferred_cuisines:     ALL_CUISINES.sample(rand(1..2)),
    disease:                [ALL_DISEASES.compact.sample, nil].sample(1).tap { |a| a.compact! }
  )

  puts "  Created user: #{user.username}"

  # ----------------------------------------------------------
  # DAY TEMPLATE
  # ----------------------------------------------------------
  DayTemplate.create!(
    user: user,
    day_name: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"].sample,
    breakfast: [nil, 1, 2, 3].sample,
    lunch:     [nil, 1, 2, 3].sample,
    dinner:    [nil, 1, 2, 3].sample
  )

  # ----------------------------------------------------------
  # WEEK → 7 DAYS → DISHES
  # ----------------------------------------------------------
  week = Week.create!(
    user: user,
    month: rand(1..12)
  )

  # Track ingredients needed across the week for shopping list
  ingredient_totals = Hash.new { |h, k| h[k] = { amount: 0.0, unit: nil } }

  7.times do |day_index|
    day = Day.create!(
      week: week,
      date: DateTime.now.beginning_of_week + day_index.days
    )

    rand(1..3).times do
      recipe = recipe_records.sample
      dish = Dish.create!(
        day: day,
        recipe: recipe,
        portions: rand(1..3),
        category: CATEGORIES.sample
      )

      # Accumulate shopping totals
      recipe.recipe_items.each do |ri|
        key = [ri.ingredient_id, ri.unit]
        ingredient_totals[key][:amount] += ri.amount * dish.portions
        ingredient_totals[key][:unit]    = ri.unit
        ingredient_totals[key][:ingredient_id] = ri.ingredient_id
      end
    end
  end

  # ----------------------------------------------------------
  # SHOPPING ITEMS (aggregated from week's dishes)
  # ----------------------------------------------------------
  ingredient_totals.each do |(_ingredient_id, _unit), data|
    ShoppingItem.create!(
      week: week,
      ingredient_id: data[:ingredient_id],
      total: data[:amount].round(2),
      unit: data[:unit],
      purchased: false
    )
  end

  # ----------------------------------------------------------
  # FAVORITES (1–5 random recipes)
  # ----------------------------------------------------------
  recipe_records.sample(rand(1..5)).each do |recipe|
    Favorite.create!(user: user, recipe: recipe)
  end
end

puts "✅ Seed complete!"