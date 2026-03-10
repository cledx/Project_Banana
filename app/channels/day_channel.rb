class DayChannel < ApplicationCable::Channel
    def subscribed
      stream_from "day_#{params[:day_id]}"
    end
  end