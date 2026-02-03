class AddPhoneToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :phone, :string
    add_column :users, :cgu_accepted, :boolean, default: false, null: false
    add_column :users, :cgu_accepted_at, :datetime
  end
end
