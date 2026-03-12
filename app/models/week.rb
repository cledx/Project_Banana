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
      puts "*" * 30
      puts "attributes from week: #{attributes}"
      puts "*" * 30
    next_week = Ai::WeekGen.new(user).generate_week(attributes)
  end
end
