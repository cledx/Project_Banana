class DishesController < ApplicationController
  def show
    @dish = Dish.find(params[:id])
    @recipe = @dish.recipe
    redirect_to recipe_path(@recipe)
  end

  def create
    if params[:new_id] == "generate"
      @dish = Dish.create!(
        recipe: Recipe.all.sample,
        day_id: params["dish"]["day_id"],
        category: params["dish"]["category"],
        portions: 2
      )

      DishJob.perform_later(@dish.id, "regenerate")

      redirect_back fallback_location: root_path,
                    notice: "Generating your meal... It will be ready in a few moments 🍳"
    else
      @dish = Dish.create(dish_params)

      redirect_back fallback_location: root_path,
                    notice: "Dish added successfully!"
    end
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
