class UsersController < ApplicationController
  before_action :set_user, only: %i[settings update_settings]

  def settings
    @user.allergies = []
    @user.preferred_cuisines = []
  end

  def update_settings
    if @user.update(user_params)
      redirect_to new_week_path
    else
      render :settings, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    permitted = params.require(:user).permit(
      preferred_cuisines: [],
      preferred_ingredients: [],
      undesireable_ingredients: [],
      allergies: [],
      disease: []
    )
    %i[preferred_cuisines preferred_ingredients undesireable_ingredients allergies disease].each do |field|
      permitted[field] = permitted[field].reject(&:blank?) if permitted[field]
    end
    permitted
  end
end
