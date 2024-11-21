class BookingsController < ApplicationController
  before_action :authenticate_user! # S'assurer que l'utilisateur est connecté
  before_action :set_booking, only: [:show, :destroy]
  before_action :set_car, only: [:new, :create]

  def index
    @bookings = current_user.bookings
  end

  def new
    @booking = Booking.new
  end

  def create
    @booking = current_user.bookings.build(booking_params)
    @booking.car = @car

    if @booking.save
      redirect_to booking_path(@booking), notice: 'Réservation créée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def destroy
    if @booking.user == current_user 
      @booking.destroy
      redirect_to bookings_path, notice: 'Réservation annulée avec succès.'
    else
      redirect_to bookings_path, alert: "Vous n'avez pas la permission de supprimer cette réservation."
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def set_car
    @car = Car.find(params[:car_id])
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date)
  end
end
