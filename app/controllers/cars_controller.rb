class CarsController < ApplicationController
  before_action :authenticate_user! # S'assurer que l'utilisateur est connecté
  before_action :set_car, only: %i[show edit update destroy]
  before_action :authorize_owner, only: %i[edit update destroy]

  # GET /cars
  def index
    # Liste toutes les voitures disponibles
    @cars = Car.all
  end

  # GET /cars/:id
  def show
    # @car est défini dans le `before_action :set_car`
  end

  # GET /cars/new
  def new
    # Prépare une nouvelle voiture pour le formulaire
    @car = Car.new
  end

  # POST /cars
  def create
    # Crée une nouvelle voiture associée au propriétaire (utilisateur connecté)
    @car = current_user.cars.build(car_params)
    if @car.save
      redirect_to @car, notice: 'Voiture ajoutée avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /cars/:id/edit
  def edit
    # @car est défini dans le `before_action :set_car`
  end

  # PATCH/PUT /cars/:id
  def update
    if @car.update(car_params)
      redirect_to @car, notice: 'Voiture mise à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /cars/:id
  def destroy
    @car.destroy
    redirect_to cars_path, notice: 'Voiture supprimée avec succès.'
  end

  private

  # Définit la voiture actuelle à partir des paramètres :id
  def set_car
    @car = Car.find(params[:id])
  end

  # Vérifie si l'utilisateur connecté est le propriétaire de la voiture
  def authorize_owner
    return if @car.user == current_user

    redirect_to cars_path, alert: "Vous n'avez pas la permission de modifier ou supprimer cette voiture."
  end

  # Strong parameters pour la création/mise à jour des voitures
  def car_params
    params.require(:car).permit(:category, :brand, :model, :year, :adress, :price, :options, :status, photos: [])
  end
end
