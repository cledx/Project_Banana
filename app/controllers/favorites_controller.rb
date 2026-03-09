class FavoritesController < ApplicationController
  def index
    @favorites = current_user.favorites.includes(:recipe)
  end

  def create
    recipe = Recipe.find(params[:recipe_id])

    Favorite.create(
      user: current_user,
      recipe: recipe
    )

    redirect_back(fallback_location: root_path)
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy

    redirect_back(fallback_location: root_path)
  end
end
