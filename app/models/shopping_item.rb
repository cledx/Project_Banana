class ShoppingItem < ApplicationRecord
  belongs_to :ingredient
  belongs_to :week
  has_many :days, through: :week
  has_many :dishes, through: :days
  validates :total, :unit, presence: true

  def dishes_with_ingredient
    dishes.joins(recipe: :recipe_items).where(recipes: { recipe_items: { ingredient: ingredient_id } }).distinct
  end
end
