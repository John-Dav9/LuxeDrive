class SuperAdmin::BaseController < ApplicationController
  include Authorizable
  before_action :authenticate_user!
  before_action :require_super_admin

  layout 'super_admin'

  private

  def require_super_admin
    return if current_user&.super_admin?

    redirect_to root_path, alert: "Accès refusé. Vous devez être super administrateur."
  end
end
