class ChangeColumnModel < ActiveRecord::Migration[7.2]
  def change
    rename_column :cars, :modele, :model
  end
end
