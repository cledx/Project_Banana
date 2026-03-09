class AddImageUrlToRecipe < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :image_url, :string
  end
end
