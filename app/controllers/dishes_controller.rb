class DishesController < ApplicationController
  def show
    @dish = Dish.find(params[:id])
    @recipe = @dish.recipe
    redirect_to recipe_path(@recipe)
  end

  def create
    @dish = Dish.create(dish_params)
  end

  def update
    # This is where we would update the dish, for a given day.
    @dish = Dish.find(params[:id])
    @dish.update(dish_params)
  end

  private

  def dish_params
    params.require(:dish).permit(:recipe_id, :day_id, :portions, :category)
  end
end
