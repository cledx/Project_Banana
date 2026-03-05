class ShoppingItemsController < ApplicationController
  def index
    @week = Week.find(params[:week_id])
    # This is to prevent users from accessing shopping lists that they don't own.
    # Similar to the week controller, we can do it this way, or we can just use the current_user method.
    # Maybe something like this:
    # @week = current_user.weeks.last
    # But if we decide to generate a week in advance, this might mess with that.
    # Although if we generate automatically a user's week on say... a Wednesday, that shouldn't interfere with a user's shopping list experience as they should've already purchased their week's groceries by then so changing the list shouldn't be an issue.]

    # I agree with the above but we only need one week for the demo so might not need to think about this.
    redirect_to root_path, alert: "You are not authorized to access this shopping list." if @week.user != current_user
    @shopping_items = @week.shopping_items.all
    @items_remaining = @shopping_items.count { |i| !i.purchased }
  end

  def update
    @shopping_item = ShoppingItem.find(params[:id])
    @shopping_item.update(set_params)
  end

  private

  def set_params
    params.require(:shopping_item).permit(:purchased)
  end
end
