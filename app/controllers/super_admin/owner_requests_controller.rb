class SuperAdmin::OwnerRequestsController < SuperAdmin::BaseController
  before_action :set_owner_request, only: %i[show approve reject needs_contract send_contract]

  def index
    @owner_requests = OwnerRequest.includes(:user).order(created_at: :desc).page(params[:page]).per(20)
    @owner_requests = @owner_requests.where(status: params[:status]) if params[:status].present?
    if params[:query].present?
      q = "%#{params[:query]}%"
      @owner_requests = @owner_requests.joins(:user).where("users.email ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ?", q, q, q)
    end
    render "super_admin/owner_requests_index"
  end

  def show
    render "super_admin/owner_requests_show"
  end

  def approve
    update_status!("approved", note: params[:note])
    @owner_request.user.update(role: :admin_client)
    redirect_to super_admin_owner_request_path(@owner_request), notice: "Demande approuvée."
  end

  def reject
    update_status!("rejected", note: params[:rejection_reason], rejection_reason: params[:rejection_reason])
    redirect_to super_admin_owner_request_path(@owner_request), alert: "Demande refusée."
  end

  def needs_contract
    update_status!("needs_contract", note: params[:note])
    redirect_to super_admin_owner_request_path(@owner_request), notice: "Contrat demandé."
  end

  def send_contract
    message = params[:message].to_s.strip
    OwnerRequestMailer.send_contract(@owner_request, message).deliver_now
    @owner_request.log_event!("contract_sent", actor: current_user, note: message.presence)
    Notification.create!(
      user: @owner_request.user,
      kind: "owner_request_contract",
      title: "Contrat prestataire envoyé",
      body: "Le contrat prestataire est disponible pour signature.",
      link_path: owner_request_path
    )
    redirect_to super_admin_owner_request_path(@owner_request), notice: "Contrat envoyé au prestataire."
  end

  private

  def set_owner_request
    @owner_request = OwnerRequest.find(params[:id])
  end

  def update_status!(new_status, note: nil, rejection_reason: nil)
    from_status = @owner_request.status
    @owner_request.assign_attributes(
      status: new_status,
      reviewed_by: current_user,
      approved_at: new_status == "approved" ? Time.current : nil,
      rejected_at: new_status == "rejected" ? Time.current : nil,
      needs_contract_at: new_status == "needs_contract" ? Time.current : nil,
      rejection_reason: rejection_reason
    )
    @owner_request.save(validate: false)
    @owner_request.log_event!(
      "status_change",
      actor: current_user,
      note: note,
      from_status: from_status,
      to_status: new_status
    )
    notify_user(@owner_request, new_status)
  end

  def notify_user(owner_request, new_status)
    Notification.create!(
      user: owner_request.user,
      kind: "owner_request_status",
      title: "Statut de votre dossier: #{new_status.humanize}",
      body: "Votre dossier prestataire est maintenant: #{new_status}",
      link_path: owner_request_path
    )
    OwnerRequestMailer.user_status_updated(owner_request).deliver_now
  end
end
