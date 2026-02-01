module Authorizable
  extend ActiveSupport::Concern

  private

  def require_super_admin
    return if current_user&.super_admin?

    redirect_to root_path, alert: "Accès refusé. Vous devez être super administrateur."
  end

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: "Accès refusé. Vous devez être administrateur."
  end

  def require_admin_client
    return if current_user&.admin_client? || current_user&.super_admin?

    redirect_to root_path, alert: "Accès refusé. Vous devez être propriétaire de voitures."
  end

  def user_not_authorized
    flash[:alert] = "Vous n'avez pas la permission d'effectuer cette action."
    redirect_to(request.referer || root_path)
  end
end
