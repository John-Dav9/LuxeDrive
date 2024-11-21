class ChangeColumnAdress < ActiveRecord::Migration[7.2]
  def change
    rename_column :cars, :adress, :address
    add_column :cars, :photo_url, :string
  end
end
