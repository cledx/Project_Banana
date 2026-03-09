class WeekChannel < ApplicationCable::Channel
    def subscribed
      stream_from "week_#{params[:week_id]}"
    end
  end