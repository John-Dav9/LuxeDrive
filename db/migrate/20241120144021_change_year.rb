class ChangeYear < ActiveRecord::Migration[7.2]
  def change
    remove_column :cars, :year
    add_column :cars, :year, :integer
  end
end
