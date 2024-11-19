class CreateOffers < ActiveRecord::Migration[7.2]
  def change
    create_table :offers do |t|
      t.string :name
      t.string :adress
      t.integer :price
      t.boolean :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
