class AddPaypalFieldsToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :paypal_order_id, :string
    add_column :bookings, :paypal_capture_id, :string
  end
end
