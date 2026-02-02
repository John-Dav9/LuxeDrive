class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

    case event.type
    when "payment_intent.succeeded"
      intent = event.data.object
      booking = Booking.find_by(id: intent.metadata["booking_id"]) ||
                Booking.find_by(stripe_payment_intent_id: intent.id)
      finalize_payment(booking, intent.id) if booking
    when "checkout.session.completed"
      session = event.data.object
      booking = Booking.find_by(stripe_session_id: session.id)
      finalize_payment(booking, session.payment_intent) if booking && session.payment_status == "paid"
    end

    render json: { status: "ok" }
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    render json: { error: "invalid payload" }, status: :bad_request
  end

  private

  def finalize_payment(booking, intent_id)
    return if booking.payment_status == "paid"

    booking.update(
      payment_status: "paid",
      stripe_payment_intent_id: intent_id,
      paid_at: Time.current,
      status: "pending"
    )
    return if booking.owner_notified_at.present?

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
