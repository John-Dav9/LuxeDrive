class PaypalWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.raw_post
    return head :bad_request if payload.blank?

    headers = {
      "PAYPAL-AUTH-ALGO" => request.headers["PAYPAL-AUTH-ALGO"],
      "PAYPAL-CERT-URL" => request.headers["PAYPAL-CERT-URL"],
      "PAYPAL-TRANSMISSION-ID" => request.headers["PAYPAL-TRANSMISSION-ID"],
      "PAYPAL-TRANSMISSION-SIG" => request.headers["PAYPAL-TRANSMISSION-SIG"],
      "PAYPAL-TRANSMISSION-TIME" => request.headers["PAYPAL-TRANSMISSION-TIME"]
    }

    return head :unauthorized unless PaypalCheckout.verify_webhook?(headers, payload)

    data = JSON.parse(payload)
    if data["event_type"] == "CHECKOUT.ORDER.APPROVED"
      order_id = data.dig("resource", "id")
      booking = Booking.find_by(paypal_order_id: order_id)
      if booking
        booking.update(payment_status: "paid", status: "pending", paid_at: Time.current)
        if booking.owner_notified_at.blank?
          BookingMailer.owner_new_booking(booking).deliver_now
          Notification.create!(
            user: booking.car.user,
            booking: booking,
            kind: "booking_new",
            title: "Nouvelle reservation",
            body: "Nouvelle reservation pour #{booking.car.brand} #{booking.car.model}",
            link_path: owner_bookings_path
          )
          booking.update(owner_notified_at: Time.current)
        end
      end
    end

    head :ok
  rescue JSON::ParserError
    head :bad_request
  end
end
