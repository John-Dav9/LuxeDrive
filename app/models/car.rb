class Car < ApplicationRecord
  belongs_to :user
  has_many_attached :photos
  has_many :bookings, dependent: :destroy

  CATEGORIES = ['Berline', 'SUV', 'Sportive', 'Luxe', 'Électrique', 'Cabriolet', '4x4'].freeze

  validates :brand, presence: true, length: { minimum: 2, maximum: 50 }
  validates :model, presence: true, length: { minimum: 1, maximum: 50 }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :year, presence: true,
                   numericality: { only_integer: true,
                                   greater_than_or_equal_to: 1900,
                                   less_than_or_equal_to: Date.current.year + 1 }
  validates :address, presence: true, length: { minimum: 5, maximum: 200 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [true, false] }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  serialize :photo_order, coder: JSON

  scope :available, -> { where(status: true) }
  scope :unavailable, -> { where(status: false) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :search_by, lambda { |query|
    if query.present?
      where("brand ILIKE ? OR model ILIKE ? OR address ILIKE ?",
            "%#{query}%", "%#{query}%", "%#{query}%")
    end
  }

  def available_between?(start_date, end_date)
    return false unless status

    conflicting_bookings = bookings.where(
      "(checkin_date <= ? AND checkout_date >= ?) OR
       (checkin_date <= ? AND checkout_date >= ?) OR
       (checkin_date >= ? AND checkout_date <= ?)",
      end_date, start_date,
      start_date, end_date,
      start_date, end_date
    ).where(status: ['accepted', 'completed'])

    conflicting_bookings.empty?
  end

  def under_option_for?(start_date, end_date)
    return false if start_date.blank? || end_date.blank?

    bookings.where(status: 'pending').where(
      "(checkin_date <= ? AND checkout_date >= ?) OR
       (checkin_date <= ? AND checkout_date >= ?) OR
       (checkin_date >= ? AND checkout_date <= ?)",
      end_date, start_date,
      start_date, end_date,
      start_date, end_date
    ).exists?
  end

  def main_photo
    ordered_photos.first if photos.attached?
  end

  def ordered_photos
    return photos unless photo_order.present?

    ordered = photo_order.filter_map do |id|
      photos.find { |photo| photo.id.to_s == id.to_s }
    end

    ordered + photos.reject { |photo| ordered.include?(photo) }
  end
end
