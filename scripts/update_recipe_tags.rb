#!/usr/bin/env ruby
# Updates recipe tags: adds allergen tags from ingredients, and Vegetarian/Vegan where applicable.

require "json"

ALLERGEN_RULES = {
  "peanuts" => ->(name) { name =~ /peanut/i },
  "tree nuts" => ->(name) { name =~ /\b(almond|walnut|cashew|pecan|pistachio|hazelnut|macadamia|pine nut|tree nut)s?\b/i },
  "shellfish" => ->(name) { name =~ /\b(shrimp|crab|lobster|scallop|clam|mussel|oyster|shellfish)\b/i },
  "dairy" => ->(name) { name =~ /\b(milk|cheese|butter|cream|yogurt|whey|feta|parmesan|mozzarella|dairy)\b/i && name !~ /coconut milk/i },
  "gluten" => ->(name) { name =~ /\b(wheat|flour|breadcrumb|pasta|bread|barley|rye|soy sauce|tamari|tortilla)\b/i },
  "soy" => ->(name) { name =~ /\b(soy|tofu|tempeh|edamame|tamari)\b/i },
  "eggs" => ->(name) { name =~ /\begg(s)?\b/i },
  "fish" => ->(name) { name =~ /\b(fish|salmon|tuna|cod|tilapia|trout|haddock|sardine|anchovy)\b/i }
}.freeze

MEAT_FISH_KEYWORDS = /\b(chicken|pork|beef|lamb|turkey|duck|fish|salmon|tuna|cod|tilapia|shrimp|crab|lobster|scallop|clam|mussel|oyster|ground beef|ground pork|sirloin|flank|drumstick|thighs?|tenderloin|meatball)\b/i

def ingredient_names(recipe)
  (recipe["ingredients"] || []).map { |i| (i["name"] || "").to_s }.join(" ").downcase
end

def detect_allergens(recipe)
  names = (recipe["ingredients"] || []).map { |i| (i["name"] || "").to_s }
  found = []
  ALLERGEN_RULES.each do |tag, pred|
    found << tag if names.any? { |n| pred.call(n) }
  end
  found
end

def vegetarian?(recipe)
  return true if recipe["category"] == "Plant-Protein"
  text = ingredient_names(recipe)
  !MEAT_FISH_KEYWORDS.match?(text)
end

def vegan?(recipe)
  return false unless vegetarian?(recipe)
  names = ingredient_names(recipe)
  ALLERGEN_RULES.slice("dairy", "eggs").each do |tag, pred|
    return false if pred.call(names)
  end
  true
end

path = File.expand_path("../db/data/recipesV3.json", __dir__)
data = JSON.parse(File.read(path))

data["data"].each do |recipe|
  tags = (recipe["tags"] || []).dup
  tags.reject! { |t| ALLERGEN_RULES.key?(t) } # remove existing allergen tags so we re-add consistently

  detect_allergens(recipe).each { |tag| tags << tag unless tags.include?(tag) }
  tags << "Vegetarian" if vegetarian?(recipe) && !tags.include?("Vegetarian")
  tags << "Vegan" if vegan?(recipe) && !tags.include?("Vegan")

  recipe["tags"] = tags
end

File.write(path, JSON.pretty_generate(data))
puts "Updated #{path}"
