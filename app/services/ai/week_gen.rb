class Ai::WeekGenerator
    def initialize(user)
      @user = user
    end

    def generate_week
        @week = Week.new
        @week.user = @user
        # This is to get the month of the week after the current week.
        @week.month = (Date.today + 7).beginning_of_week.month
        @week.save
        7.times do |i|
        # This sends the week, the date of the day, and the user to the day generator to generate the day.
            Ai::DayGenerator.new(@week, (Date.today + 7).beginning_of_week + i.days).generate_day
        end
    end
end