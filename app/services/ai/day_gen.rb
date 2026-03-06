class Ai::DayGen
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
        day_template = @week.user.day_templates.find_by(day_name: @date.strftime("%A"))
        puts "Day template: #{day_template}"
        unless day_template.nil?
            [day_template.breakfast, day_template.lunch, day_template.dinner].each_with_index do |portions, index|
                if portions.present?
                    Ai::DishGen.new(@day, portions, ["breakfast", "lunch", "dinner"][index]).generate_dish
                end
            end
        end
        @day.save
        @day
    end

end