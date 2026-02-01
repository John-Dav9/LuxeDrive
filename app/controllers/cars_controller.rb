class CarsController < ApplicationController
  include Authorizable
  before_action :authenticate_user!, except: %i[index show]
  before_action :require_admin_client, only: %i[new create]
  before_action :set_car, only: %i[show edit update destroy]
  before_action :authorize_owner, only: %i[edit update destroy]

  def index
    @cars = Car.includes(:user, photos_attachments: :blob)

    # Filtres
    @cars = @cars.available if params[:available] == 'true'
    @cars = @cars.by_category(params[:category]) if params[:category].present?
    @cars = @cars.search_by(params[:query]) if params[:query].present?

    # Tri
    if params[:sort] == 'price_asc'
      @cars = @cars.order(price: :asc)
    elsif params[:sort] == 'price_desc'
      @cars = @cars.order(price: :desc)
    else
      @cars = @cars.order(created_at: :desc)
    end

    # Pagination
    @cars = @cars.page(params[:page]).per(12)
    @categories = Car::CATEGORIES
  end

  def show
    @booking = Booking.new
  end

  def new
    @car = Car.new
  end

  def edit
  end

  def create
    @car = current_user.cars.build(car_params)
    if @car.save
      redirect_to @car, notice: 'Voiture ajoutée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @car.update(normalized_car_params)
      redirect_to @car, notice: 'Voiture mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @car.bookings.where(status: ['pending', 'accepted']).any?
      redirect_to @car, alert: "Impossible de supprimer une voiture avec des réservations actives."
    elsif @car.destroy
      redirect_to root_path, notice: 'Voiture supprimée avec succès.'
    else
      redirect_to @car, alert: "La voiture n'a pas pu être supprimée."
    end
  end

  def destroy_photo
    @car = Car.find(params[:id])
    authorize_owner
    photo = @car.photos.find(params[:photo_id])
    photo.purge
    if @car.photo_order.present?
      @car.update(photo_order: @car.photo_order.reject { |id| id.to_s == params[:photo_id].to_s })
    end
    redirect_to edit_car_path(@car), notice: "Photo supprimée."
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def authorize_owner
    return if current_user.can_manage_car?(@car)

    redirect_to cars_path, alert: "Vous n'avez pas la permission de modifier ou supprimer cette voiture."
    return
  end

  def car_params
    params.require(:car).permit(:category, :brand, :model, :year, :address, :description, :price, :status, :photo_order, photos: [])
  end

  def normalized_car_params
    permitted = car_params
    if permitted[:photo_order].is_a?(String)
      permitted[:photo_order] = permitted[:photo_order].split(",").map(&:strip).reject(&:empty?)
    end
    permitted
  end
end
