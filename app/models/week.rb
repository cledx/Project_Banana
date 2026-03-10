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

  def generate_next_week
    days.order(:date).each do |day|
      day.generate_day do |category|
        dishes = day.dishes.where(category: category)
        html = ApplicationController.render(
          partial: "weeks/dish_list",
          locals: { dishes: dishes, day: day, category: category }
        )
        ActionCable.server.broadcast("week_#{user.weeks[-2].id}", {
          day_id: day.id,
          category: category,
          html: html
        })
      end
    end
  end
end
