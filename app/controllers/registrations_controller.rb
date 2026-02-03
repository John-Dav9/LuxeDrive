class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def new
    build_resource({})
    respond_with resource do |format|
      format.html { render "pages/registration" }
    end
  end

  def create
    build_resource(sign_up_params)
    if resource.save
      if resource.respond_to?(:cgu_accepted_at) && resource.cgu_accepted
        resource.update(cgu_accepted_at: Time.current)
      end
      sign_up(resource_name, resource)
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource do |format|
        format.html { render "pages/registration", status: :unprocessable_entity }
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name phone phone_country cgu_accepted])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name phone phone_country cgu_accepted])
  end
end
