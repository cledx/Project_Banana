class Ai::DayGenerator
    def initialize(week, date)
      @week = week
      @date = date
    end

    def generate_day
        @day = Day.new({
            date: @date,
            week: @week
        })
        # This gets the day template for the user's day of the week.
        day_template = @week.user.day_template.find_by(day_name: @date.strftime("%A"))
        [day_template.breakfast, day_template.lunch, day_template.dinner].each_with_index do |dish_num, index|
            if dish_num.present?
                dish = Ai::DishGenerator.new(@day, dish_num, ["breakfast", "lunch", "dinner"][index])
                dish.save
            end
        end
        @day.save
    end

end