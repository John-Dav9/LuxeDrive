class Owner::BookingsController < Owner::BaseController
  def index
    @bookings = current_user.bookings_as_owner
                            .includes(:user, car: [photos_attachments: :blob])
                            .where.not(status: "pending_payment")
                            .order(created_at: :desc)
                            .page(params[:page]).per(20)
    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
  end
end
