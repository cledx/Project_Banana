class ShoppingItem < ApplicationRecord
  belongs_to :ingredient
  belongs_to :week
  validates :total, :unit, presence: true
end
