class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :user

  def total_price
    return 0 unless checkin_date && checkout_date && car.price.present?
 
    number_of_days = (checkout_date - checkin_date).to_i + 1 # ajouter +1 si les deux jours inclus sont comptés comme des jours pleins.
    number_of_days * car.price
  end
end
