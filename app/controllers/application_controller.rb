class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  allow_browser versions: :modern
  stale_when_importmap_changes

  protected

  # Devise n'accepte que email + password par défaut.
  # Cette méthode autorise le champ :name lors de l'inscription et de la mise à jour du profil.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
