class WeeksController < ApplicationController
  def show
    @week = Week.find(params[:id])
    response.headers["Turbo-Cache-Control"] = "no-cache"
    @today = @week.days.find { |day| day.date.to_date == Date.current }
    @number_of_weeks = @week.next_week ? 2 : 1
    @calendar_days = @week.days
    @calendar_days += @week.next_week.days if @week.next_week
    @recipe_first_day = {}
    @dish_colours = {}
    [@week, @week.next_week].each do |week|
      next unless week

      week.days.each do |day|
        day.dishes.each do |dish|
          next if @dish_colours.key?(dish.recipe_id)

          color = 0
          color += 1 while @dish_colours.value?(color)
          @dish_colours[dish.recipe_id] = color
        end
      end
    end

    @calendar_days.each do |day|
      day.dishes.each do |dish|
        @recipe_first_day[dish.recipe_id] ||= day.date.strftime("%A")
      end
    end
    redirect_to root_path, alert: "You are not authorized to access this week." if @week.user != current_user
  end

  def new
    @week = Week.new
    @user = current_user
  end

  def create
    if params[:day_templates].present?
      day_templates = {
        monday: {
          breakfast: params[:day_templates][:monday][:breakfast].to_i,
          lunch: params[:day_templates][:monday][:lunch].to_i,
          dinner: params[:day_templates][:monday][:dinner].to_i
        },
        tuesday: {
          breakfast: params[:day_templates][:tuesday][:breakfast].to_i,
          lunch: params[:day_templates][:tuesday][:lunch].to_i,
          dinner: params[:day_templates][:tuesday][:dinner].to_i
        },
        wednesday: {
          breakfast: params[:day_templates][:wednesday][:breakfast].to_i,
          lunch: params[:day_templates][:wednesday][:lunch].to_i,
          dinner: params[:day_templates][:wednesday][:dinner].to_i
        },
        thursday: {
          breakfast: params[:day_templates][:thursday][:breakfast].to_i,
          lunch: params[:day_templates][:thursday][:lunch].to_i,
          dinner: params[:day_templates][:thursday][:dinner].to_i
        },
        friday: {
          breakfast: params[:day_templates][:friday][:breakfast].to_i,
          lunch: params[:day_templates][:friday][:lunch].to_i,
          dinner: params[:day_templates][:friday][:dinner].to_i
        },
        saturday: {
          breakfast: params[:day_templates][:saturday][:breakfast].to_i,
          lunch: params[:day_templates][:saturday][:lunch].to_i,
          dinner: params[:day_templates][:saturday][:dinner].to_i
        },
        sunday: {
          breakfast: params[:day_templates][:sunday][:breakfast].to_i,
          lunch: params[:day_templates][:sunday][:lunch].to_i,
          dinner: params[:day_templates][:sunday][:dinner].to_i
        }
      }
    else
      day_templates = nil
    end
    current_user.weeks.first.destroy if current_user.weeks.first.days.nil?
    @week = Week.new(user: current_user)
    @week.month = (Date.today + 7).beginning_of_week.month
    week_start = (Date.today + 7).beginning_of_week(:monday)
    7.times do |i|
      @week.days.build(date: week_start + i.days)
    end
    @week.save!

    WeekJob.perform_later(@week.id, day_templates)
    redirect_to week_path(current_user.weeks[-2].id)
  end
end
