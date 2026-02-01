class SuperAdmin::UsersController < SuperAdmin::BaseController
  before_action :set_user, only: %i[show edit update destroy change_role]

  def index
    @users = User.order(created_at: :desc).page(params[:page]).per(20)
    @users = @users.where(role: params[:role]) if params[:role].present?
    return unless params[:query].present?

    @users = @users.where("email ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ?",
                          "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to super_admin_user_path(@user), notice: 'Utilisateur mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to super_admin_users_path, alert: "Vous ne pouvez pas supprimer votre propre compte."
    elsif @user.destroy
      redirect_to super_admin_users_path, notice: 'Utilisateur supprimé avec succès.'
    else
      redirect_to super_admin_users_path, alert: "Erreur lors de la suppression."
    end
  end

  def change_role
    new_role = params[:role]

    if @user == current_user && new_role != 'super_admin'
      redirect_to super_admin_users_path, alert: "Vous ne pouvez pas modifier votre propre rôle."
    elsif User::ROLES.keys.include?(new_role) && @user.update(role: new_role)
      redirect_to super_admin_user_path(@user),
                  notice: "Rôle changé en #{I18n.t("activerecord.attributes.user.roles.#{new_role}")}."
    else
      redirect_to super_admin_user_path(@user), alert: "Erreur lors du changement de rôle."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role)
  end
end
