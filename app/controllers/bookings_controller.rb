class BookingsController < ApplicationController
  before_action :authenticate_user! # S'assurer que l'utilisateur est connecté
  before_action :set_booking, only: [:show, :destroy]
  before_action :set_car, only: [:new, :create]

  # GET /cars/:car_id/bookings/new
  def new
    @booking = Booking.new
  end

  # POST /cars/:car_id/bookings
  def create
    @booking = current_user.bookings.build(booking_params)
    @booking.car = @car

    if @booking.save
      redirect_to booking_path(@booking), notice: 'Réservation créée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /bookings
  def index
    @bookings = current_user.bookings # Réservations du locataire connecté
  end

  # GET /bookings/:id
  def show
    # La réservation est déjà définie par le `before_action :set_booking`
  end

  # DELETE /bookings/:id
  def destroy
    if @booking.user == current_user # Vérifie que l'utilisateur connecté est bien le locataire
      @booking.destroy
      redirect_to bookings_path, notice: 'Réservation annulée avec succès.'
    else
      redirect_to bookings_path, alert: "Vous n'avez pas la permission de supprimer cette réservation."
    end
  end

  private

  # Définit la réservation à partir des paramètres :id
  def set_booking
    @booking = Booking.find(params[:id])
  end

  # Définit la voiture à partir des paramètres :car_id
  def set_car
    @car = Car.find(params[:car_id])
  end

  # Strong parameters pour les réservations
  def booking_params
    params.require(:booking).permit(:start_date, :end_date)
  end
end
