class AddCloudinaryPublicIdToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :cloudinary_public_id, :string
    add_index :recipes, :cloudinary_public_id
  end
end
