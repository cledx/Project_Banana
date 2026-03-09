class WeekJob < ApplicationJob
    queue_as :default

    def perform(week_id)
        week = Week.find(week_id)
        week.generate_next_week
    end
end