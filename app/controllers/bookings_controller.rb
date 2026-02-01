class BookingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: %i[show accept reject cancel payment payment_success payment_cancel start_payment payment_intent_success paypal_create paypal_capture]
  before_action :set_car, only: %i[new create]
  before_action :authorize_owner, only: %i[accept reject]
  before_action :authorize_renter, only: %i[cancel payment start_payment payment_success payment_cancel]

  def index
    @bookings = current_user.bookings
                            .includes(car: [:user, { photos_attachments: :blob }])
                            .order(created_at: :desc)
                            .page(params[:page]).per(10)
  end

  def show
  end

  def new
    @booking = Booking.new
  end

  def create
    @booking = current_user.bookings.build(booking_params)
    @booking.car = @car
    @booking.status = 'pending_payment'

    if @booking.save
      redirect_to payment_booking_path(@booking)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    if @booking.update(status: 'accepted')
      redirect_to owner_bookings_path, notice: 'Réservation acceptée.'
    else
      redirect_to owner_bookings_path, alert: 'Erreur lors de l\'acceptation.'
    end
  end

  def reject
    if @booking.update(status: 'rejected')
      redirect_to owner_bookings_path, notice: 'Réservation refusée.'
    else
      redirect_to owner_bookings_path, alert: 'Erreur lors du refus.'
    end
  end

  def cancel
    if @booking.can_be_cancelled? && @booking.update(status: 'cancelled')
      if @booking.refundable? && @booking.stripe_payment_intent_id.present?
        Stripe::Refund.create(payment_intent: @booking.stripe_payment_intent_id)
        @booking.update(refunded_at: Time.current, payment_status: "refunded")
      end
      redirect_to bookings_path, notice: 'Réservation annulée avec succès. Le remboursement sera traité.'
    else
      redirect_to bookings_path, alert: "Impossible d'annuler cette réservation."
    end
  end

  def payment_success
    session = Stripe::Checkout::Session.retrieve(@booking.stripe_session_id)
    if session.payment_status == "paid"
      @booking.update(
        payment_status: "paid",
        stripe_payment_intent_id: session.payment_intent,
        paid_at: Time.current,
        status: "pending"
      )
      notify_owner_if_needed(@booking)
      redirect_to dashboard_path, notice: "Paiement confirmé. Votre réservation est en attente."
    else
      redirect_to dashboard_path, alert: "Paiement non confirmé."
    end
  end

  def payment_cancel
    @booking.update(status: "cancelled") if @booking.status == "pending_payment"
    redirect_to payment_failed_booking_path(@booking)
  end

  def payment_failed
  end

  def payment
  end

  def start_payment
    intent = Stripe::PaymentIntent.create(
      amount: (@booking.total_price * 100).to_i,
      currency: "eur",
      metadata: { booking_id: @booking.id }
    )
    @booking.update(stripe_payment_intent_id: intent.id, payment_status: "unpaid")
    respond_to do |format|
      format.html { redirect_to payment_booking_path(@booking) }
      format.json { render json: { client_secret: intent.client_secret } }
    end
  end

  def payment_intent_success
    intent_id = params[:payment_intent] || @booking.stripe_payment_intent_id
    intent = Stripe::PaymentIntent.retrieve(intent_id)
    if intent.status == "succeeded"
      @booking.update(
        payment_status: "paid",
        stripe_payment_intent_id: intent.id,
        paid_at: Time.current,
        status: "pending"
      )
      notify_owner_if_needed(@booking)
      redirect_to dashboard_path, notice: "Paiement confirmé. Votre réservation est en attente."
    else
      redirect_to payment_failed_booking_path(@booking)
    end
  end

  def paypal_create
    order = PaypalCheckout.create_order(@booking)
    if order["id"].present?
      @booking.update(paypal_order_id: order["id"])
      render json: order
    else
      render json: { error: "paypal_create_failed" }, status: :unprocessable_entity
    end
  end

  def paypal_capture
    order_id = params[:order_id] || @booking.paypal_order_id
    capture = PaypalCheckout.capture_order(order_id)
    if capture["status"] == "COMPLETED"
      capture_id = capture.dig("purchase_units", 0, "payments", "captures", 0, "id")
      @booking.update(
        payment_status: "paid",
        paid_at: Time.current,
        status: "pending",
        paypal_capture_id: capture_id
      )
      notify_owner_if_needed(@booking)
      render json: { ok: true, redirect_url: dashboard_path }
    else
      render json: { error: "paypal_capture_failed" }, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def set_car
    @car = Car.find(params[:car_id])
  end

  def authorize_owner
    return if @booking.can_be_managed_by?(current_user)

    redirect_to root_path, alert: "Vous n'avez pas la permission de gérer cette réservation."
  end

  def authorize_renter
    return if @booking.user == current_user

    redirect_to root_path, alert: "Vous n'avez pas la permission d'annuler cette réservation."
  end

  def booking_params
    params.require(:booking).permit(
      :checkin_date,
      :checkout_date,
      :pickup_mode,
      :pickup_address,
      :pickup_time,
      :return_time,
      :drivers_count,
      :driver_age,
      :license_years,
      :premium_insurance,
      :child_seat,
      :gps,
      :terms_accepted,
      :deposit_card
    )
  end

  def build_line_items(booking)
    days = booking.number_of_days
    items = []
    items << {
      price_data: {
        currency: "eur",
        unit_amount: (booking.car.price * 100).to_i,
        product_data: { name: "#{booking.car.brand} #{booking.car.model} - Prix/jour" }
      },
      quantity: days
    }

    options_per_day = booking.options_price_per_day
    if options_per_day.positive?
      items << {
        price_data: {
          currency: "eur",
          unit_amount: (options_per_day * 100).to_i,
          product_data: { name: "Options/jour" }
        },
        quantity: days
      }
    end

    if booking.delivery_fee.positive?
      items << {
        price_data: {
          currency: "eur",
          unit_amount: (booking.delivery_fee * 100).to_i,
          product_data: { name: "Livraison" }
        },
        quantity: 1
      }
    end

    if booking.extra_driver_fee.positive?
      items << {
        price_data: {
          currency: "eur",
          unit_amount: (booking.extra_driver_fee * 100).to_i,
          product_data: { name: "Conducteurs supplémentaires" }
        },
        quantity: 1
      }
    end

    if booking.young_driver_fee.positive?
      items << {
        price_data: {
          currency: "eur",
          unit_amount: (booking.young_driver_fee * 100).to_i,
          product_data: { name: "Jeune conducteur" }
        },
        quantity: 1
      }
    end

    items
  end

  def notify_owner_if_needed(booking)
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
