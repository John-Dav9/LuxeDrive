class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :booking, null: true, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.text :body
      t.string :link_path
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [:user_id, :read_at]
  end
end
