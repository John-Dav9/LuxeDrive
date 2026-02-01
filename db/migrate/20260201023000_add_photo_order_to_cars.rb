class AddPhotoOrderToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :photo_order, :text
  end
end
