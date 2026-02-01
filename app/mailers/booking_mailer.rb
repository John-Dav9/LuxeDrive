class BookingMailer < ApplicationMailer
  default from: "no-reply@luxedrive.com"

  def owner_new_booking(booking)
    @booking = booking
    @owner = booking.car.user
    mail to: @owner.email, subject: "Nouvelle reservation pour #{booking.car.brand} #{booking.car.model}"
  end

  def owner_reminder(booking)
    @booking = booking
    @owner = booking.car.user
    mail to: @owner.email, subject: "Rappel: reservation en attente (#{booking.car.brand} #{booking.car.model})"
  end

  def renter_expiring(booking)
    @booking = booking
    @renter = booking.user
    mail to: @renter.email, subject: "Votre reservation expire dans 15 minutes"
  end

  def owner_expired(booking)
    @booking = booking
    @owner = booking.car.user
    mail to: @owner.email, subject: "Reservation expiree (#{booking.car.brand} #{booking.car.model})"
  end
end
