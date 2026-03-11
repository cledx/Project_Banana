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
    @dish = Dish.find(params[:id])
    if params[:new_id].present?
      DishJob.perform_later(@dish.id, params[:new_id])
    else
      @dish.update(dish_params)
    end
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
