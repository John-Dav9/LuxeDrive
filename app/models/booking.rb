class Booking < ApplicationRecord
  belongs_to :car
  belongs_to :user

  STATUSES = ['pending_payment', 'pending', 'accepted', 'rejected', 'cancelled', 'completed', 'expired'].freeze
  PENDING_TIMEOUT_HOURS = 2

  validates :checkin_date, presence: true
  validates :checkout_date, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :pickup_mode, presence: true, on: :create
  validates :pickup_address, presence: true, on: :create
  validates :pickup_time, presence: true, on: :create
  validates :return_time, presence: true, on: :create
  validates :drivers_count, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, on: :create
  validates :driver_age, numericality: { only_integer: true, greater_than_or_equal_to: 18 }, on: :create
  validates :license_years, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, on: :create
  validates :terms_accepted, acceptance: true, on: :create
  validates :deposit_card, acceptance: true, on: :create
  validate :checkout_date_after_checkin_date
  validate :dates_cannot_be_in_past, on: :create
  validate :car_must_be_available, on: :create
  validate :car_not_under_option, on: :create

  before_validation :set_pickup_address_for_pickup, on: :create

  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :expired, -> { where(status: 'expired') }
  scope :upcoming, -> { where('checkin_date >= ?', Date.current).where(status: ['pending', 'accepted']) }
  scope :past, -> { where('checkout_date < ?', Date.current) }
  scope :current, -> { where('checkin_date <= ? AND checkout_date >= ?', Date.current, Date.current) }
  scope :pending_expired, -> { where(status: 'pending').where('created_at < ?', PENDING_TIMEOUT_HOURS.hours.ago) }

  def total_price
    return 0 unless checkin_date && checkout_date && car.price.present?

    base_total = number_of_days * car.price
    options_total = options_price_per_day * number_of_days
    base_total + options_total + delivery_fee + extra_driver_fee + young_driver_fee
  end

  def paid?
    payment_status == "paid"
  end

  def refundable?
    paid? && can_be_cancelled?
  end

  def number_of_days
    return 0 unless checkin_date && checkout_date

    (checkout_date - checkin_date).to_i
  end

  def options_price_per_day
    total = 0
    total += 25 if premium_insurance
    total += 8 if child_seat
    total += 6 if gps
    total
  end

  def delivery_fee
    pickup_mode == "delivery" ? 60 : 0
  end

  def extra_driver_fee
    extra = (drivers_count || 1) - 1
    return 0 if extra <= 0

    extra * 12
  end

  def young_driver_fee
    return 0 unless driver_age

    driver_age < 25 ? 15 : 0
  end

  def can_be_cancelled?
    return false unless ['pending', 'accepted'].include?(status)

    checkin_dt = checkin_datetime
    return false if checkin_dt.blank?

    checkin_dt >= 24.hours.from_now
  end

  def can_be_managed_by?(user)
    car.user == user
  end

  def self.expire_pending!
    pending_expired.find_each do |booking|
      booking.update(status: 'expired')
    end
  end

  private

  def checkout_date_after_checkin_date
    return if checkin_date.blank? || checkout_date.blank?

    return unless checkout_date <= checkin_date

    errors.add(:checkout_date, "doit être après la date de début")
  end

  def dates_cannot_be_in_past
    return if checkin_date.blank?

    return unless checkin_date < Date.current

    errors.add(:checkin_date, "ne peut pas être dans le passé")
  end

  def car_must_be_available
    return if checkin_date.blank? || checkout_date.blank? || car.blank?

    return if car.available_between?(checkin_date, checkout_date)

    errors.add(:base, "Cette voiture n'est pas disponible pour ces dates")
  end

  def car_not_under_option
    return if car.blank?
    return unless car.under_option_for?(checkin_date, checkout_date)

    errors.add(:base, "Cette voiture est sous option.")
  end

  def checkin_datetime
    return if checkin_date.blank?

    time = pickup_time || Time.zone.parse("12:00")
    Time.zone.local(checkin_date.year, checkin_date.month, checkin_date.day, time.hour, time.min)
  end

  def set_pickup_address_for_pickup
    return unless pickup_mode == "pickup"

    self.pickup_address = car.address if pickup_address.blank?
  end
end
