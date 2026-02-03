class OwnerRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_visitor
  before_action :set_owner_request, only: %i[show edit update]

  def new
    if current_user.owner_request.present?
      redirect_to owner_request_path
      return
    end
    @owner_request = OwnerRequest.new
    render "pages/owner_request_new"
  end

  def create
    @owner_request = current_user.build_owner_request(owner_request_params)
    @owner_request.status = "pending"
    @owner_request.contract_accepted_at = Time.current if @owner_request.contract_accepted?
    @owner_request.cgu_accepted_at = Time.current if @owner_request.cgu_accepted?

    if @owner_request.save
      notify_super_admins(@owner_request)
      @owner_request.log_event!("submitted", actor: current_user, to_status: "pending")
      redirect_to owner_request_path, notice: "Votre demande a été envoyée."
    else
      render "pages/owner_request_new", status: :unprocessable_entity
    end
  end

  def show
    render "pages/owner_request_show"
  end

  def edit
    redirect_to owner_request_path if @owner_request.approved?
    render "pages/owner_request_edit"
  end

  def update
    return redirect_to owner_request_path if @owner_request.approved?

    previous_status = @owner_request.status
    @owner_request.assign_attributes(owner_request_params)
    if @owner_request.rejected?
      @owner_request.status = "pending"
      @owner_request.rejection_reason = nil
      @owner_request.rejected_at = nil
    end
    @owner_request.contract_accepted_at = Time.current if @owner_request.contract_accepted? && @owner_request.contract_accepted_at.blank?
    @owner_request.cgu_accepted_at = Time.current if @owner_request.cgu_accepted? && @owner_request.cgu_accepted_at.blank?

    if @owner_request.save
      @owner_request.log_event!("updated", actor: current_user, from_status: previous_status, to_status: @owner_request.status)
      notify_super_admins(@owner_request, resubmission: true)
      redirect_to owner_request_path, notice: "Votre dossier a été mis à jour."
    else
      render "pages/owner_request_edit", status: :unprocessable_entity
    end
  end

  private

  def require_visitor
    return if current_user.visitor?

    redirect_to root_path, alert: "Cette page est réservée aux locataires."
  end

  def set_owner_request
    @owner_request = current_user.owner_request
    return if @owner_request.present?

    redirect_to new_owner_request_path
  end

  def owner_request_params
    params.require(:owner_request).permit(
      :civility,
      :first_name,
      :last_name,
      :phone,
      :cgu_accepted,
      :birth_date,
      :birth_city,
      :birth_country,
      :nationality,
      :gender,
      :address_line1,
      :address_line2,
      :postal_code,
      :city,
      :country,
      :id_document_type,
      :id_number,
      :id_expires_on,
      :driver_license_number,
      :driver_license_expires_on,
      :proof_of_address_issued_on,
      :residence_country,
      :bank_iban,
      :bank_bic,
      :bank_holder_name,
      :work_permit_required,
      :work_permit_expires_on,
      :signature_method,
      :contract_accepted,
      :id_document,
      :driver_license,
      :proof_of_address,
      :bank_rib,
      :selfie,
      :work_permit,
      :signed_contract
    )
  end

  def notify_super_admins(owner_request, resubmission: false)
    User.where(role: :super_admin).find_each do |admin|
      Notification.create!(
        user: admin,
        kind: "owner_request",
        title: resubmission ? "Dossier prestataire mis à jour" : "Nouvelle demande prestataire",
        body: "Demande de #{owner_request.user.full_name}",
        link_path: super_admin_owner_request_path(owner_request)
      )
      OwnerRequestMailer.admin_new_request(admin, owner_request).deliver_now
    end
  end
end
