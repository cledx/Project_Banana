class Day < ApplicationRecord
  has_many :dishes, dependent: :destroy
  has_many :recipes, through: :dishes
  belongs_to :week
  validates :date, presence: true

  def previous_day
    week.days.order(:date).where("date < ?", date).last
  end

  def next_day
    week.days.order(:date).where("date > ?", date).first
  end

  def generate_day(day_template = week.user.day_templates.find_by(day_name: date.strftime("%A")))
    
    Ai:DayGen.new(self, day_template).generate_day
    self
  end
end
