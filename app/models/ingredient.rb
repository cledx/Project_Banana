class Ingredient < ApplicationRecord
  has_many :shopping_items, :recipe_items
  has_many :recipes, through: :recipe_items
  validates :name, presence: true
end
