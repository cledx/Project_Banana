class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :recipe_id, uniqueness: { scope: :user_id }
end
