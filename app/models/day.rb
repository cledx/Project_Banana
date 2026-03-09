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

  def generate_day
    day_template = week.user.day_templates.find_by(day_name: date.strftime("%A"))
    unless day_template.nil?
      [day_template.breakfast, day_template.lunch, day_template.dinner].each_with_index do |portions, index|
        Ai::DishGen.new(self, portions, ["breakfast", "lunch", "dinner"][index]).generate_dish if portions.present?
      end
    end
    self
  end
end
