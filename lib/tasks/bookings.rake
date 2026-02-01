namespace :bookings do
  desc "Expire pending bookings older than the configured timeout"
  task expire_pending: :environment do
    bookings = Booking.pending_expired.to_a
    Booking.expire_pending!
    bookings.each do |booking|
      BookingMailer.owner_expired(booking).deliver_now
      Notification.create!(
        user: booking.car.user,
        booking: booking,
        kind: "booking_expired",
        title: "Reservation expiree",
        body: "La reservation pour #{booking.car.brand} #{booking.car.model} a expire.",
        link_path: owner_bookings_path
      )
    end
    puts "Expired #{bookings.count} pending booking(s)."
  end

  desc "Send reminders to owners for pending bookings after 1h"
  task remind_owners: :environment do
    bookings = Booking.pending
                       .where(owner_reminded_at: nil)
                       .where('created_at < ?', 1.hour.ago)
                       .where('created_at > ?', Booking::PENDING_TIMEOUT_HOURS.hours.ago)
    bookings.find_each do |booking|
      BookingMailer.owner_reminder(booking).deliver_now
      Notification.create!(
        user: booking.car.user,
        booking: booking,
        kind: "booking_reminder",
        title: "Reservation en attente",
        body: "Rappel: reservation en attente pour #{booking.car.brand} #{booking.car.model}",
        link_path: owner_bookings_path
      )
      booking.update(owner_reminded_at: Time.current)
    end
    puts "Owner reminders sent: #{bookings.count}"
  end

  desc "Warn renters 15 minutes before expiration"
  task warn_renters: :environment do
    bookings = Booking.pending
                       .where(renter_warning_sent_at: nil)
                       .where('created_at < ?', (Booking::PENDING_TIMEOUT_HOURS.hours.ago + 15.minutes))
                       .where('created_at > ?', Booking::PENDING_TIMEOUT_HOURS.hours.ago)
    bookings.find_each do |booking|
      BookingMailer.renter_expiring(booking).deliver_now
      Notification.create!(
        user: booking.user,
        booking: booking,
        kind: "booking_expiring",
        title: "Reservation bientot expiree",
        body: "Votre reservation expirera bientot si le proprietaire ne repond pas.",
        link_path: bookings_path
      )
      booking.update(renter_warning_sent_at: Time.current)
    end
    puts "Renter warnings sent: #{bookings.count}"
  end
end
