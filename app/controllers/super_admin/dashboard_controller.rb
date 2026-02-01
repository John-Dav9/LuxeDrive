class SuperAdmin::DashboardController < SuperAdmin::BaseController
  def index
    @total_users = User.count
    @total_admin_clients = User.admin_client.count
    @total_visitors = User.visitor.count
    @total_cars = Car.count
    @total_bookings = Booking.count
    @pending_bookings = Booking.pending.count
    @recent_users = User.order(created_at: :desc).limit(10)
    @recent_bookings = Booking.includes(:user, :car).order(created_at: :desc).limit(10)
  end
end
