class RemovePhotoUrlFromCars < ActiveRecord::Migration[7.2]
  def change
    remove_column :cars, :photo_url, :string
  end
end
