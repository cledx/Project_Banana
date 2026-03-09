class User < ApplicationRecord
  has_many :favorites
  has_many :favorite_recipes, through: :favorites, source: :recipe
  has_many :weeks
  has_many :day_templates
  has_many :days, through: :weeks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ALL_ALLERGIES = ["peanuts", "tree nuts", "shellfish", "dairy", "gluten", "soy", "eggs", "fish"]

  # Returns dishes from the week before the given date (by calendar week).
  # reference_date can be a Date or Time; defaults to today.
  def previous_week_dishes(reference_date = Date.current)
    ref = reference_date.to_date
    prev_week_start = ref.beginning_of_week - 7.days
    prev_week_end   = prev_week_start + 6.days
    range = prev_week_start.beginning_of_day..prev_week_end.end_of_day
    days_in_prev_week = days.where(date: range).order(:date)
    Dish.where(day_id: days_in_prev_week.select(:id)).includes(:recipe)
  end
end
