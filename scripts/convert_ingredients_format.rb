#!/usr/bin/env ruby
# Converts recipe ingredients to format: name, amount, unit, modifier

require "json"

UNITS = %w[
  cups cup tbsp tsp g ml lb oz pint pints can cans clove cloves
  package packages block blocks head bunch pinch dash
  inch inches slice slices fillet fillets piece pieces
].freeze

def parse_amount(raw)
  raw = raw.to_s.strip
  return { amount: raw, unit: nil, modifier: nil } if raw.empty?

  amount_part = nil
  rest = raw

  # Fraction first (e.g. "1/2, juiced")
  if raw =~ /\A(\d+\/\d+)\s*,?\s*(.*)\z/i
    amount_part = $1
    rest = $2.strip
  # Number then rest (e.g. "2 lb boneless", "4 tbsp, divided")
  elsif raw =~ /\A(\d+\.?\d*)\s+(.*)\z/
    amount_part = $1
    rest = $2.strip
  else
    return { amount: raw, unit: nil, modifier: nil }
  end

  unit = nil
  modifier = nil
  rest_lower = rest.downcase

  # Pattern: "unit modifier" or "unit, modifier"
  if rest_lower =~ /\A(lb|oz|g|ml|cups?|tbsp|tsp|pints?|cans?|cloves?|packages?|blocks?|fillets?|slices?)\s*,?\s*(.*)\z/
    unit = $1.downcase
    unit = "cups" if unit == "cup"
    unit = "cloves" if unit == "clove"
    unit = "pints" if unit == "pint"
    unit = "cans" if unit == "can"
    unit = "packages" if unit == "package"
    unit = "blocks" if unit == "block"
    unit = "fillets" if unit == "fillet"
    unit = "slices" if unit == "slice"
    modifier = $2.strip
    modifier = nil if modifier.empty?
    return { amount: amount_part, unit: unit, modifier: modifier }
  end

  # "3 medium", "1 large", "2 small"
  if rest_lower =~ /\A(medium|large|small)\s*,?\s*(.*)\z/
    modifier = $1
    modifier += ", #{$2}" if $2 && !$2.strip.empty?
    modifier = nil if modifier.to_s.strip.empty?
    return { amount: amount_part, unit: "piece", modifier: modifier }
  end

  # "2 cups florets", "3 cups, trimmed"
  if rest_lower =~ /\A(cups?)\s+,?\s*(.*)\z/
    unit = "cups"
    modifier = $2.strip
    modifier = nil if modifier.empty?
    return { amount: amount_part, unit: unit, modifier: modifier }
  end

  # "1 (28 oz) can" or similar
  if rest =~ /\A\([^)]+\)\s*(can|cans)?\s*,?\s*(.*)\z/i
    unit = ($1 || "can").downcase
    unit = "cans" if unit == "can" && amount_part.to_f >= 2
    modifier = $2.strip
    modifier = nil if modifier.empty?
    return { amount: amount_part, unit: unit, modifier: modifier }
  end

  # First word as unit (e.g. "whole", "bunch")
  if rest =~ /\A(\S+)\s*,?\s*(.*)\z/
    w = $1.downcase
    remainder = $2.strip
    if %w[whole piece pieces bunch head pinch dash].include?(w) || UNITS.include?(w)
      unit = w
      modifier = remainder.empty? ? nil : remainder
    else
      unit = "piece"
      modifier = rest
    end
  else
    unit = "piece"
    modifier = rest.empty? ? nil : rest
  end

  modifier = nil if modifier.to_s.strip.empty?
  { amount: amount_part, unit: unit, modifier: modifier }
end

path = File.expand_path("../db/data/recipesV3.json", __dir__)
data = JSON.parse(File.read(path))

data["data"].each do |recipe|
  next unless recipe["ingredients"].is_a?(Array)

  recipe["ingredients"] = recipe["ingredients"].map do |ing|
    name = ing["name"].to_s.strip
    raw_amount = ing["amount"].to_s.strip
    parsed = parse_amount(raw_amount)

    new_ing = {
      "name" => name,
      "amount" => parsed[:amount],
      "unit" => parsed[:unit],
      "modifier" => parsed[:modifier]
    }
    new_ing.delete("modifier") if new_ing["modifier"].nil? || new_ing["modifier"].to_s.empty?
    new_ing
  end
end

File.write(path, JSON.pretty_generate(data))
puts "Converted ingredients in #{path}"
