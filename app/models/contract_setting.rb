class ContractSetting < ApplicationRecord
  belongs_to :updated_by, class_name: "User", optional: true

  def self.current
    first || create!(
      company_name: "LuxeDrive",
      company_address: "[À compléter]",
      company_vat: "[À compléter]",
      company_email: "contact@luxedrive.fr"
    )
  end
end
