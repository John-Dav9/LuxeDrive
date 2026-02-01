class AddBookingDetailsToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :pickup_mode, :string
    add_column :bookings, :pickup_address, :string
    add_column :bookings, :pickup_time, :time
    add_column :bookings, :return_time, :time
    add_column :bookings, :drivers_count, :integer
    add_column :bookings, :driver_age, :integer
    add_column :bookings, :license_years, :integer
    add_column :bookings, :premium_insurance, :boolean, default: false, null: false
    add_column :bookings, :child_seat, :boolean, default: false, null: false
    add_column :bookings, :gps, :boolean, default: false, null: false
    add_column :bookings, :terms_accepted, :boolean, default: false, null: false
  end
end
