class Week < ApplicationRecord
  has_many :shopping_items
  has_many :days, dependent: :destroy
  has_many :dishes, through: :days
  has_many :recipes, through: :dishes
  has_many :recipe_items, through: :recipes
  has_many :ingredients, through: :shopping_items
  belongs_to :user

  def next_week
    user.weeks.where("id > ?", id).order(:id).first
  end

  def generate_next_week(day_templates = nil)
    puts "day templates from week model #{day_templates}"
    next_week = Ai::WeekGen.new(user).generate_week((days.first.date + 7).beginning_of_week.month,
                                                    (days.first.date + 7).beginning_of_week, day_templates)
  end
end
