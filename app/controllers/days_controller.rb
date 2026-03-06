class DaysController < ApplicationController
  before_action :set_day, only: %i[show]
  def show
    @dishes = @day.dishes
    redirect_to root_path, alert: "You are not authorized to access this day." if @day.week.user != current_user
  end

  private

  def day_params
    params.require(:day).permit(:date)
  end

  def set_day
    @day = Day.find(params[:id])
  end
end
