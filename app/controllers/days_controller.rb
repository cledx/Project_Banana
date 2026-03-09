class DaysController < ApplicationController
  def show
    @week = Week.find(params[:week_id])
    if params[:id].to_i.to_s == params[:id]
      @day = @week.days.find(params[:id])
    else
      @day = @week.days.where("date::date = ?", Date.parse(params[:id])).first
    end
    @dishes = @day.dishes
    redirect_to root_path, alert: "You are not authorized to access this day." if @day.week.user != current_user
  end

  private

  def day_params
    params.require(:day).permit(:date)
  end
end
