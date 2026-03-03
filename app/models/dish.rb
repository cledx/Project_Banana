class Dish < ApplicationRecord
  belongs_to :day
  belongs_to :recipe
  validates :category, presence: true
  validates :portions, presence: true, numericality: { only_integer: true }
end
