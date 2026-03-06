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
    if params[:new_id] == "regenerate"
      @new_dish = Ai::DishGen.new(@dish.day, @dish.portions, @dish.category).generate_dish
      @dish.update(recipe_id: @new_dish.recipe_id, category: @new_dish.category)
      @new_dish.destroy
      redirect_to week_day_path(@dish.day.week, @dish.day)
    elsif params[:new_id].present?
      @new_dish = Recipe.find(params[:new_id])
      @dish.update(recipe_id: @new_dish.id)
      redirect_to week_day_path(@dish.day.week, @dish.day)
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
