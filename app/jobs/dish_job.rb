class DishJob < ApplicationJob
  queue_as :default

    def perform(dish_id, new_id)
        dish = Dish.find(dish_id)
        dishes = Dish.includes(:day).includes(:week).where(recipe_id: dish.recipe_id).where(day:{week:dish.day.week})
        if new_id == "regenerate"
            new_dish = Ai::DishGen.new(dish.id).generate_dish
            dishes.each do |d|
                d.update(recipe_id: new_dish.recipe_id)
            end
        elsif new_id.present?
            new_dish = Recipe.find(new_id)
            dish.update(recipe_id: new_dish.id)
        end

        day = dish.day
        date = day.date.strftime('%Y-%m-%e')
        category = dish.category
        category_dishes = day.dishes.where(category: category)
        html = ApplicationController.render(
            partial: "days/dish_list",
            locals: { day: day, dishes: category_dishes, category: category, current_user: day.week.user }
        )
        ActionCable.server.broadcast("date", {
            day_id: day.id,
            category: category,
            html: html
        })
    end
end
