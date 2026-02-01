class PagesController < ApplicationController
  before_action :authenticate_user!, only: %i[dashboard owner_dashboard owner_bookings]

  def home
    @featured_cars = Car.available.includes(:user, photos_attachments: :blob).limit(6).order(created_at: :desc)
    @categories = Car::CATEGORIES
  end

  def dashboard
    @my_bookings = current_user.bookings
                               .includes(car: [:user, { photos_attachments: :blob }])
                               .order(created_at: :desc)
                               .page(params[:page]).per(5)
  end

  def owner_bookings
    @owner_bookings = current_user.bookings_as_owner
                                  .includes(:user, car: [photos_attachments: :blob])
                                  .order(created_at: :desc)
                                  .page(params[:page]).per(10)
  end

  def owner_dashboard
    redirect_to owner_root_path
  end

  def about
  end

  def legal
  end

  def privacy
  end

  def cookies
  end

  def mentions_legales
  end

  def faq
  end

  def pricing
  end

  def owner_guide
  end
end
