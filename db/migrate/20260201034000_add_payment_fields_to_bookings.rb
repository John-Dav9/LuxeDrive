class AddPaymentFieldsToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :payment_status, :string, default: "unpaid", null: false
    add_column :bookings, :stripe_session_id, :string
    add_column :bookings, :stripe_payment_intent_id, :string
    add_column :bookings, :paid_at, :datetime
    add_column :bookings, :refunded_at, :datetime
  end
end
