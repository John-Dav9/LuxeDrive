class AddIdentityFieldsToOwnerRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :owner_requests, :civility, :string
    add_column :owner_requests, :first_name, :string
    add_column :owner_requests, :last_name, :string
    add_column :owner_requests, :birth_date, :date
    add_column :owner_requests, :birth_city, :string
    add_column :owner_requests, :birth_country, :string
    add_column :owner_requests, :nationality, :string
    add_column :owner_requests, :gender, :string
    add_column :owner_requests, :address_line1, :string
    add_column :owner_requests, :address_line2, :string
    add_column :owner_requests, :postal_code, :string
    add_column :owner_requests, :city, :string
    add_column :owner_requests, :country, :string
    add_column :owner_requests, :phone, :string
    add_column :owner_requests, :cgu_accepted, :boolean, default: false, null: false
    add_column :owner_requests, :cgu_accepted_at, :datetime
  end
end
