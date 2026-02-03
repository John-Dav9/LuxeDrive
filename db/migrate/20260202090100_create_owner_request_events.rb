class CreateOwnerRequestEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :owner_request_events do |t|
      t.references :owner_request, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :from_status
      t.string :to_status
      t.text :note

      t.timestamps
    end
  end
end
