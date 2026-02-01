class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :booking, optional: true

  validates :kind, presence: true
  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }

  def mark_read!
    update(read_at: Time.current)
  end
end
