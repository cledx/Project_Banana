class WeeksController < ApplicationController
  def show
    @week = Week.find(params[:id])
    response.headers["Turbo-Cache-Control"] = "no-cache"
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
    if params[:day_templates].present?
      day_templates = {
        monday: {
          breakfast: params[:day_templates][0][:breakfast],
          lunch:     params[:day_templates][0][:lunch],
          dinner:    params[:day_templates][0][:dinner]
        },
        tuesday: {
          breakfast: params[:day_templates][1][:breakfast],
          lunch:     params[:day_templates][1][:lunch],
          dinner:    params[:day_templates][1][:dinner]
        },
        wednesday: {
          breakfast: params[:day_templates][2][:breakfast],
          lunch:     params[:day_templates][2][:lunch],
          dinner:    params[:day_templates][2][:dinner]
        },
        thursday: {
          breakfast: params[:day_templates][3][:breakfast],
          lunch:     params[:day_templates][3][:lunch],
          dinner:    params[:day_templates][3][:dinner]
        },
        friday: {
          breakfast: params[:day_templates][4][:breakfast],
          lunch:     params[:day_templates][4][:lunch],
          dinner:    params[:day_templates][4][:dinner]
        },
        saturday: {
          breakfast: params[:day_templates][5][:breakfast],
          lunch:     params[:day_templates][5][:lunch],
          dinner:    params[:day_templates][5][:dinner]
        },
        sunday: {
          breakfast: params[:day_templates][6][:breakfast],
          lunch:     params[:day_templates][6][:lunch],
          dinner:    params[:day_templates][6][:dinner]
        }
      }
    else
      day_templates = nil
    end
    current_user.weeks.first.destroy if current_user.weeks.first.days.nil?
    @week = Week.new(user: current_user)
    @week.month = (Date.today + 7).beginning_of_week.month
    @week.save!

    7.times do |i|
      Day.create!(date: (Date.today + 7).beginning_of_week + i.days, week: @week)
    end

    WeekJob.perform_later(@week.id, day_templates)
    redirect_to week_path(current_user.weeks[-2].id)
  end
end
