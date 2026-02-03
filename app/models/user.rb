class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :cars, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :bookings_as_owner, through: :cars, source: :bookings
  has_many :notifications, dependent: :destroy
  has_one :owner_request, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Système de rôles
  enum :role, { super_admin: 0, admin_client: 1, visitor: 2 }
  before_validation :set_default_role, on: :create

  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone_country, presence: true
  validates :phone, presence: true
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "format invalide" }
  validates :cgu_accepted, acceptance: true, on: :create
  validates :role, presence: true

  validate :phone_e164_for_country
  before_validation :normalize_phone_e164

  # Scopes
  scope :admins, -> { where(role: %i[super_admin admin_client]) }
  scope :clients, -> { where(role: :visitor) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    super_admin? || admin_client?
  end

  def can_manage_car?(car)
    super_admin? || car.user_id == id
  end

  def can_manage_users?
    super_admin?
  end

  def owner_request_status
    owner_request&.status || "none"
  end

  def owner_request_pending?
    owner_request&.pending? || owner_request&.needs_contract?
  end

  def set_default_role
    self.role ||= :visitor
  end

  private

  def normalize_phone_e164
    return if phone.blank? || phone_country.blank?

    parsed = Phonelib.parse(phone, phone_country)
    self.phone = parsed.e164 if parsed.valid?
  end

  def phone_e164_for_country
    return if phone.blank? || phone_country.blank?

    parsed = Phonelib.parse(phone, phone_country)
    unless parsed.valid?
      errors.add(:phone, "doit être au format international E.164 et correspondre au pays sélectionné")
    end
  end
end
