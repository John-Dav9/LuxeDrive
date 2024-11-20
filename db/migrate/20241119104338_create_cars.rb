class CreateCars < ActiveRecord::Migration[7.2]
  def change
    create_table :cars do |t|
      t.string :brand
      t.string :category
      t.string :modele 
      t.date :year
      t.string :adress
      t.integer :price
      t.boolean :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
