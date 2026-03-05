class Dish < ApplicationRecord
  belongs_to :day
  belongs_to :recipe
  has_one :week, through: :day
  validates :category, presence: true
  validates :portions, presence: true, numericality: { only_integer: true }
  after_create_commit :create_shopping_items
  after_update_commit :update_shopping_items
  after_destroy_commit :destroy_shopping_items

  def create_shopping_items
    recipe.recipe_items.each do |recipe_item|
      total_amount = recipe_item.amount * portions
      if week.shopping_items.empty?
        ShoppingItem.create(
          ingredient: recipe_item.ingredient,
          week: week,
          total: total_amount,
          unit: recipe_item.unit
        )
      else
        existing_item = week.shopping_items.find { |item| item.ingredient == recipe_item.ingredient }
        if existing_item
          existing_item.update(total: existing_item.total + total_amount)
        else
          ShoppingItem.create(
            ingredient: recipe_item.ingredient,
            week: week,
            total: total_amount,
            unit: recipe_item.unit
          )
        end
      end
    end
  end

  def update_shopping_items
    recipe.recipe_items.each do |recipe_item|
      total_amount = recipe_item.amount * portions
      existing_item = week.shopping_items.find { |item| item.ingredient == recipe_item.ingredient }
      existing_item.update(total: existing_item.total + total_amount)
    end
  end

  def destroy_shopping_items
    recipe.recipe_items.each do |recipe_item|
      total_amount = recipe_item.amount * portions
      existing_item = week.shopping_items.find { |item| item.ingredient == recipe_item.ingredient }
      existing_item.update(total: existing_item.total - total_amount)
      existing_item.destroy if existing_item.total.zero?
    end
  end
end
