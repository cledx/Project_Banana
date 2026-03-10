class User < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :weeks, dependent: :destroy
  has_many :day_templates, dependent: :destroy
  has_many :favorite_recipes, through: :favorites, source: :recipe
  has_many :days, through: :weeks
  has_many :dishes, through: :days
  after_create :create_initial_week, :create_day_templates
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

  def favorited?(recipe)
    favorites.exists?(recipe_id: recipe.id)
  end

  private

  def create_initial_week
    weeks.create!(month: Date.current.month)
  end

  def create_day_templates
    days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
    days.each do |day|
      day_templates.create!(day_name: day, breakfast: 0, lunch: 0, dinner: 2)
    end
  end
end
