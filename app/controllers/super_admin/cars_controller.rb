class SuperAdmin::CarsController < SuperAdmin::BaseController
  before_action :set_car, only: %i[edit update destroy]

  def index
    @cars = Car.includes(:user, photos_attachments: :blob)
               .order(created_at: :desc)
               .page(params[:page]).per(20)
  end

  def edit
  end

  def update
    if @car.update(normalized_car_params)
      redirect_to super_admin_cars_path, notice: "Voiture mise à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @car.destroy
      redirect_to super_admin_cars_path, notice: 'Voiture supprimée avec succès.'
    else
      redirect_to super_admin_cars_path, alert: "Erreur lors de la suppression."
    end
  end

  def destroy_photo
    photo = @car.photos.find(params[:photo_id])
    photo.purge
    if @car.photo_order.present?
      @car.update(photo_order: @car.photo_order.reject { |id| id.to_s == params[:photo_id].to_s })
    end
    redirect_to edit_super_admin_car_path(@car), notice: "Photo supprimée."
  end

  private

  def set_car
    @car = Car.find(params[:id])
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
