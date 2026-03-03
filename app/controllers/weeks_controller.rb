class WeeksController < ApplicationController
  def show
    @week = Week.find(params[:id])
  end

  def create
    @week = Week.new
    @week.save
    redirect_to week_path(@week)
  end
end
