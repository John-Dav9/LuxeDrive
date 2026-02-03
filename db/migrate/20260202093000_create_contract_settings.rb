class CreateContractSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :contract_settings do |t|
      t.string :company_name
      t.string :company_address
      t.string :company_vat
      t.string :company_email
      t.string :contract_version, null: false, default: "3.0"
      t.string :jurisdiction, null: false, default: "Union Européenne / France"
      t.references :updated_by, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
