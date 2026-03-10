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
    DishJob.perform_later(@dish.id, params[:new_id]) if params[:new_id].present?
  end

  def destroy
    @dish = Dish.find(params[:id])
    @dish.destroy
    redirect_back_or_to root_path, status: :see_other
  end

  private

  def dish_params
    params.require(:dish).permit(:recipe_id, :day_id, :portions, :category)
  end
end
