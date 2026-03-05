class Week < ApplicationRecord
  has_many :shopping_items
  has_many :days
  has_many :dishes, through: :days
  has_many :ingredients, through: :shopping_items
  belongs_to :user
end
