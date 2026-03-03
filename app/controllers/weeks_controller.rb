class WeeksController < ApplicationController
  def show
    @week = Week.find(params[:id])
  end

  def create
    @week = Week.new
    @week.save
  end
end
