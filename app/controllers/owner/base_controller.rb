class Owner::BaseController < ApplicationController
  include Authorizable
  before_action :authenticate_user!
  before_action :require_owner

  layout "owner"

  private

  def require_owner
    return if current_user&.admin_client?

    redirect_to root_path, alert: "Accès réservé aux propriétaires."
  end
end
