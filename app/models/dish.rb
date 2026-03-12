class Dish < ApplicationRecord
  belongs_to :day
  belongs_to :recipe
  has_many :recipe_items, through: :recipe
  has_one :week, through: :day
  validates :category, presence: true
  validates :portions, presence: true, numericality: { only_integer: true }
  after_commit :update_items

  def update_items
    puts "Updating items for dish: #{id}"
    ingredients_hash = {}
    week.dishes.each do |dish|
      portions = dish.portions
      dish.recipe_items.each do |recipe_item|
        key = [recipe_item.ingredient, recipe_item.unit]
        ingredients_hash[key] ||= 0
        ingredients_hash[key] += recipe_item.amount * portions
      end
    end

    ingredients_hash.each do |(ingredient, unit), total|
      # p ingredient
      existing_item = week.shopping_items.find { |item| item.ingredient == ingredient && item.unit = unit }
      if existing_item
        existing_item.update(total: total, unit: unit)
      else
        ShoppingItem.create(
          ingredient: ingredient,
          week: week,
          total: total,
          unit: unit
        )
      end
    end
  end
end
