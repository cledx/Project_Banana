class Week < ApplicationRecord
  has_many :shopping_items
  has_many :days
  has_many :dishes, through: :days
  has_many :recipes, through: :dishes
  has_many :recipe_items, through: :recipes
  has_many :ingredients, through: :shopping_items
  belongs_to :user
end
