class ShoppingItemsController < ApplicationController
  def index
    @week = Week.find(params[:week_id])
    @shopping_items = @week.shopping_items.all
  end

  def update
    @shopping_item = ShoppingItem.find(params[:id])
    if @shopping_item.update(set_params)
      redirect_to week_shopping_items_path(@shopping_item.week)
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_params
    params.require(:shopping_item).permit(:purchased)
  end
end
