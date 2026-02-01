class SuperAdmin::BookingsController < SuperAdmin::BaseController
  def index
    @bookings = Booking.includes(:user, car: [:user, { photos_attachments: :blob }])
                       .order(created_at: :desc)
                       .page(params[:page]).per(20)
    @bookings = @bookings.where(status: params[:status]) if params[:status].present?
  end
end
