class UsersController < ApplicationController
  before_action :set_user, only: %i[settings update_settings]

  def settings
  end

  def update_settings
    if @user.update(user_params)
      redirect_to settings_path(current_user)
    else
      render :settings, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:allergies, :disease, :preferred_cuisines, :preferred_ingredients,
                                 :undesireable_ingredients)
  end
end
