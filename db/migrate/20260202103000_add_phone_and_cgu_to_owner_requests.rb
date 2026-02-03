class AddPhoneAndCguToOwnerRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :owner_requests, :phone, :string
    add_column :owner_requests, :cgu_accepted, :boolean, default: false, null: false
    add_column :owner_requests, :cgu_accepted_at, :datetime
  end
end
