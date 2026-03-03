class DaysController < ApplicationController
  before_action :set_day, only: %i[show update destroy]
  def show
  end

  def create
    @day = Day.new(day_params)
    if @day.save
      redirect_to week_day_path(@day)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @day.update
    if @day.save
      redirect_to week_day_path(@day)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @week = @day.week
    @day.destroy
    redirect_to week_path(@week)
  end

  private

  def day_params
    params.require(day).permit(:date)
  end

  def set_day
    @day = Day.find(params[:id])
  end
end
