class AddDescriptionToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :description, :text
  end
end
