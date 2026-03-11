class ShoppingItem < ApplicationRecord
  belongs_to :ingredient
  belongs_to :week
  has_many :days, through: :week
  has_many :dishes, through: :days

  validates :total, :unit, presence: true

  def dishes_with_ingredient
    dishes.joins(recipe: :recipe_items)
          .where(recipes: { recipe_items: { ingredient: ingredient_id } })
          .distinct
  end

  DESCRIPTORS = %w[
    fresh dried ground smoked chopped minced sliced crushed grated
    shredded diced peeled cooked uncooked raw
  ]

  def cleaned_ingredient_name
    return ingredient.name if ingredient.name.blank?

    words = ingredient.name.downcase.split
    cleaned = words - DESCRIPTORS
    cleaned.join(" ").singularize
  end

  DISPLAY_UNITS = %w[g kg ml l oz lb cup cups unit]

  BAD_UNITS = %w[
    tsp tbsp teaspoon tablespoons
    pinch dash
    slice slices
    clove cloves
    piece pieces
    handful
  ]

  def clean_unit
    return if unit.blank?

    unit
      .downcase
      .gsub(/\(.*?\)/, "") # remove parentheses
      .split
      .first
  end

  def normalized_unit
    case clean_unit
    when "gram", "grams"
      "g"
    when "milliliter", "milliliters"
      "ml"
    when "liter", "liters"
      "l"
    when "medium", "large"
      "unit"
    else
      clean_unit
    end
  end

  def display_quantity
    return nil if total.to_f.zero?
    return nil if BAD_UNITS.include?(clean_unit)

    amount = total % 1 == 0 ? total.to_i : total.round(2)

    return amount if normalized_unit.blank?

    if DISPLAY_UNITS.include?(normalized_unit)
      if normalized_unit == "unit"
        "#{amount} #{amount == 1 ? 'unit' : 'units'}"
      else
        "#{amount} #{normalized_unit}"
      end
    else
      amount
    end
  end
end
