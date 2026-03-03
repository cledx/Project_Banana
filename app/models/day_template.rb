class DayTemplate < ApplicationRecord
  belongs_to :user
  validates :day_name, presence: true
  validates :breakfast, :lunch, :dinner, presence: true, numericality: { only_integer: true }
end
