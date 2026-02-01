class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :cars, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :bookings_as_owner, through: :cars, source: :bookings
  has_many :notifications, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Système de rôles
  enum :role, { super_admin: 0, admin_client: 1, visitor: 2 }

  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :role, presence: true

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
end
