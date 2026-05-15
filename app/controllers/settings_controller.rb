class SettingsController < ApplicationController
  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to settings_path, notice: "Réglages mis à jour."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :sector)
  end
end
