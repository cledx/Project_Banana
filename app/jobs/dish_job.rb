class DishJob < ApplicationJob
  queue_as :default

  def perform(dish_id, new_id)
    dish = Dish.find(dish_id)
    if new_id == "regenerate"
      new_dish = Ai::DishGen.new(dish.day, dish.portions, dish.category).generate_dish
      dish.update(recipe_id: new_dish.recipe_id, category: new_dish.category)
      new_dish.destroy
    elsif new_id.present?
      new_dish = Recipe.find(new_id)
      dish.update(recipe_id: new_dish.id)
    end

    day = dish.day
    category = dish.category
    category_dishes = day.dishes.where(category: category)
    html = ApplicationController.render(
      partial: "days/dish_list",
      locals: { day: day, dishes: category_dishes, category: category, current_user: day.week.user }
    )
    ActionCable.server.broadcast("day_#{day.id}", {
                                   day_id: day.id,
                                   category: category,
                                   html: html
                                 })
  end
end
