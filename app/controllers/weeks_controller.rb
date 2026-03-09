class WeeksController < ApplicationController
  def show
    @week = Week.find(params[:id])
    @today = @week.days.find { |day| day.date.to_date == Date.current }
    @number_of_weeks = @week.next_week ? 2 : 1
    @calendar_days = @week.days
    @calendar_days += @week.next_week.days if @week.next_week
    # This is to prevent users from accessing weeks that they don't own.
    # We can do it this way, or we can just use the current_user method in the view.
    # I think this is a better way for us to do it, because it's simpler. But we could also have the view display the current user's week and not rely on an id param at all, which might be more elegant.

    # Wouldn't we need an id either way to see which week is the current one and to be able to navigate between weeks?
    redirect_to root_path, alert: "You are not authorized to access this week." if @week.user != current_user
  end

  def new
    @week = Week.new
  end

  def create
    @week = Week.new(user: current_user)
    @week.month = (Date.today + 7).beginning_of_week.month
    @week.save!

    7.times do |i|
      Day.create!(date: (Date.today + 7).beginning_of_week + i.days, week: @week)
    end

    WeekJob.perform_later(@week.id)
    redirect_to week_path(@week)
  end
end
