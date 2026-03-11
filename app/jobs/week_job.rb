class WeekJob < ApplicationJob
    queue_as :default

    def perform(week_id, day_templates = nil)
        week = Week.find(week_id)
        week.generate_next_week(day_templates)
    end
end