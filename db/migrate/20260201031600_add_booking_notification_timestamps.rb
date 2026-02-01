class AddBookingNotificationTimestamps < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :owner_notified_at, :datetime
    add_column :bookings, :owner_reminded_at, :datetime
    add_column :bookings, :renter_warning_sent_at, :datetime
  end
end
