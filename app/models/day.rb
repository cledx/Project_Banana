class Day < ApplicationRecord
  has_many :dishes
  has_many :recipes, through: :dishes
  belongs_to :week
  validates :date, presence: true

  def previous_day
    week.days.order(:date).where("date < ?", date).last
  end

  def next_day
    week.days.order(:date).where("date > ?", date).first
  end
end
