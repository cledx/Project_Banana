class DayChannel < ApplicationCable::Channel
    def subscribed
      stream_from "date"
    end
  end