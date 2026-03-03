class DaysController < ApplicationController
  def show
    @show = Show.find(params[:id])
  end

  def create
    @show = Show.new(day_params)
  end

  def update
  end

  def destroy
  end

  private

  def day_params
    params.require(day).permit(:date)
  end
end
