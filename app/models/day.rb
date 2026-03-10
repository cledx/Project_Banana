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

  def generate_day
    day_template = week.user.day_templates.find_by(day_name: date.strftime("%A"))

    if day_template.present?
      [day_template.breakfast, day_template.lunch, day_template.dinner].each_with_index do |portions, index|
        category = %w[breakfast lunch dinner][index]
        if portions.present?
          Ai::DishGen.new(self, portions, category).generate_dish
          yield(category) if block_given?
        end
      end
    end

    self
  end
end
