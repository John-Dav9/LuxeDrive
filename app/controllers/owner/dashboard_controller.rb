class Owner::DashboardController < Owner::BaseController
  def index
    @total_cars = current_user.cars.count
    @available_cars = current_user.cars.available.count
    @unavailable_cars = current_user.cars.unavailable.count

    owner_bookings = current_user.bookings_as_owner.where.not(status: "pending_payment")
    @total_bookings = owner_bookings.count
    @pending_bookings = owner_bookings.where(status: "pending").count
    @accepted_bookings = owner_bookings.where(status: "accepted").count

    bookings_for_revenue = current_user.bookings_as_owner
                                       .includes(:car)
                                       .where(status: %w[accepted completed])
    @total_revenue = bookings_for_revenue.sum do |booking|
      booking.car.price * booking.number_of_days
    end

    @recent_cars = current_user.cars.order(created_at: :desc).limit(5)
    @recent_bookings = current_user.bookings_as_owner
                                   .includes(:user, :car)
                                   .where.not(status: "pending_payment")
                                   .order(created_at: :desc)
                                   .limit(5)
  end
end
