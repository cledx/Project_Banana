class Day < ApplicationRecord
  belongs_to :week
  validates :date, presence: true
end
