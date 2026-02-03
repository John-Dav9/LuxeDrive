class CreateOwnerRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :owner_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :signature_method, null: false, default: 0
      t.boolean :contract_accepted, null: false, default: false
      t.datetime :contract_accepted_at
      t.datetime :submitted_at

      t.string :id_document_type
      t.string :id_number
      t.date :id_expires_on
      t.string :driver_license_number
      t.date :driver_license_expires_on
      t.date :proof_of_address_issued_on
      t.string :residence_country

      t.string :bank_iban
      t.string :bank_bic
      t.string :bank_holder_name

      t.boolean :work_permit_required, null: false, default: false
      t.date :work_permit_expires_on

      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :needs_contract_at
      t.text :rejection_reason

      t.timestamps
    end

    add_index :owner_requests, :status
  end
end
