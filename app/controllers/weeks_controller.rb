class WeeksController < ApplicationController
  def show
    @week = Week.find(params[:id])
    @today = @week.days.find { |day| day.date.to_date == Date.current }
    # This is to prevent users from accessing weeks that they don't own.
    # We can do it this way, or we can just use the current_user method in the view.
    # I think this is a better way for us to do it, because it's simpler. But we could also have the view display the current user's week and not rely on an id param at all, which might be more elegant.

    # Wouldn't we need an id either way to see which week is the current one and to be able to navigate between weeks?
    redirect_to root_path, alert: "You are not authorized to access this week." if @week.user != current_user
  end

  def create
    @week = Week.new
    week_generation
    @week.save
    redirect_to week_path(@week)
  end
end
