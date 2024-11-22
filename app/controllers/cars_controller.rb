class CarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_car, only: %i[show edit update destroy]
  before_action :authorize_owner, only: %i[edit update destroy]

  def index
    @cars = Car.all
  end

  def show
  end

  def new
    @car = Car.new
  end

  def create
    @car = Car.new(car_params)
    @car.user = current_user
    if @car.save
      redirect_to @car, notice: 'Voiture ajoutée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @car.update(car_params)
      redirect_to @car, notice: 'Voiture mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @car = set_car
    if @car.destroy
      redirect_to root_path, notice: 'Voiture supprimée avec succès.'
    else
      redirect_to car_path(@car), alert: "La voiture n'a pas pu être supprimée."
    end
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def authorize_owner
    return if @car.user == current_user

    redirect_to cars_path, alert: "Vous n'avez pas la permission de modifier ou supprimer cette voiture."
  end

  def car_params
    params.require(:car).permit(:category, :brand, :model, :year, :address, :price, :status, :photo_url)
  end
end
