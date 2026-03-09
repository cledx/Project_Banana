class FavoritesController < ApplicationController
  def index
    @recipes = current_user.favorite_recipes
  end

  def toggle
    recipe = Recipe.find(params[:recipe_id])
    favorite = current_user.favorites.find_by(recipe: recipe)

    if favorite
      favorite.destroy
    else
      current_user.favorites.create(recipe: recipe)
    end

    redirect_back(fallback_location: root_path)
  end
end
