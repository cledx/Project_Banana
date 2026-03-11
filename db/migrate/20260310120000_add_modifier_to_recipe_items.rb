class AddModifierToRecipeItems < ActiveRecord::Migration[8.1]
  def change
    add_column :recipe_items, :modifier, :string
  end
end
