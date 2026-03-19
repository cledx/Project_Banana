class Week < ApplicationRecord
  has_many :shopping_items
  has_many :days, dependent: :destroy
  has_many :dishes, through: :days
  has_many :recipes, through: :dishes
  has_many :recipe_items, through: :recipes
  has_many :ingredients, through: :shopping_items
  belongs_to :user

  def self.current_week_for_user(user)
    user.weeks.joins(:days).where("DATE(days.date) = ?", Date.current).first
  end

  def next_week
    user.weeks.where("id > ?", id).order(:id).first
  end

  def generate_next_week(day_templates = nil)
    # Use the first day of this week as a reference when available,
    # otherwise fall back to the upcoming week based on today's date.
    reference_date =
      if days.first&.date
        (days.first.date + 7).beginning_of_week
      else
        (Date.today + 7).beginning_of_week
      end

    attributes = {
      "month" => reference_date.month,
      "week_start" => reference_date,
      "day_templates" => day_templates,
      "week_id" => id
    }
    next_week = Ai::WeekGen.new(user).generate_week(attributes)

    # After the next week has been generated, broadcast an update for each day/category
    # so the *current* week (the one that contains today) can update via WeekChannel.
    current_week_for_user = Week.current_week_for_user(user) || self
    next_week.days.includes(:dishes).each do |day|
      %w[breakfast lunch dinner].each do |category|
        category_dishes = day.dishes.where(category: category)
        html = ApplicationController.render(
          partial: "weeks/day_meal_list",
          locals: { day: day, dishes: category_dishes, category: category, current_user: next_week.user }
        )

        ActionCable.server.broadcast(
          "week_#{current_week_for_user.id}",
          {
            day_id: day.id,
            category: category,
            html: html
          }
        )
      end
    end

    next_week
  end
end
