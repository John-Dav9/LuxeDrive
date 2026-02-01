class AddDepositCardToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :deposit_card, :boolean, default: false, null: false
  end
end
