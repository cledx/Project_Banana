class Recipe < ApplicationRecord
  has_many :recipe_items
  has_many :dishes
  has_many :favorites
  has_many :days, through: :dishes
  has_many :ingredients, through: :recipe_items
  has_many :favorites
  has_many :users, through: :favorites
  validates :cooktime, presence: true, numericality: { only_integer: true }
  validates :cuisine, :name, :instructions, presence: true
end
