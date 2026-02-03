class OwnerRequest < ApplicationRecord
  belongs_to :user
  belongs_to :reviewed_by, class_name: "User", optional: true
  has_many :owner_request_events, dependent: :destroy

  has_one_attached :id_document
  has_one_attached :driver_license
  has_one_attached :proof_of_address
  has_one_attached :bank_rib
  has_one_attached :selfie
  has_one_attached :work_permit
  has_one_attached :signed_contract

  enum :status, { pending: 0, needs_contract: 1, approved: 2, rejected: 3 }
  enum :signature_method, { manual_upload: 0, e_signature: 1 }

  validates :id_document_type, presence: true
  validates :id_number, presence: true
  validates :driver_license_number, presence: true
  validates :residence_country, presence: true
  validates :bank_iban, presence: true
  validates :bank_holder_name, presence: true
  validates :proof_of_address_issued_on, presence: true
  validates :signature_method, presence: true
  validates :civility, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birth_date, presence: true
  validates :birth_city, presence: true
  validates :birth_country, presence: true
  validates :nationality, presence: true
  validates :gender, presence: true
  validates :address_line1, presence: true
  validates :postal_code, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :phone, presence: true
  validates :cgu_accepted, acceptance: true

  validate :phone_e164_for_country
  before_validation :normalize_phone_e164

  validate :required_documents_present
  validate :work_permit_if_required
  validate :contract_requirements

  before_validation :set_submitted_at, on: :create

  scope :documents_expiring_soon, lambda {
    where("id_expires_on IS NOT NULL AND id_expires_on <= ?", 30.days.from_now.to_date)
      .or(where("driver_license_expires_on IS NOT NULL AND driver_license_expires_on <= ?", 30.days.from_now.to_date))
      .or(where("work_permit_expires_on IS NOT NULL AND work_permit_expires_on <= ?", 30.days.from_now.to_date))
  }

  def log_event!(action, actor: nil, note: nil, from_status: nil, to_status: nil)
    owner_request_events.create!(
      action: action,
      actor: actor,
      note: note,
      from_status: from_status,
      to_status: to_status
    )
  end

  def missing_documents
    [].tap do |missing|
      missing << "id_document" unless id_document.attached?
      missing << "driver_license" unless driver_license.attached?
      missing << "proof_of_address" unless proof_of_address.attached?
      missing << "bank_rib" unless bank_rib.attached?
      missing << "selfie" unless selfie.attached?
      missing << "work_permit" if work_permit_required && !work_permit.attached?
      missing << "signed_contract" if manual_upload? && !signed_contract.attached?
    end
  end

  def incomplete?
    missing_documents.any?
  end

  def documents_expiring_soon?
    [id_expires_on, driver_license_expires_on, work_permit_expires_on].compact.any? do |date|
      date <= 30.days.from_now.to_date
    end
  end

  private

  def required_documents_present
    errors.add(:id_document, "doit être fourni") unless id_document.attached?
    errors.add(:driver_license, "doit être fourni") unless driver_license.attached?
    errors.add(:proof_of_address, "doit être fourni") unless proof_of_address.attached?
    errors.add(:bank_rib, "doit être fourni") unless bank_rib.attached?
    errors.add(:selfie, "doit être fournie") unless selfie.attached?
  end

  def work_permit_if_required
    return unless work_permit_required

    errors.add(:work_permit, "doit être fourni") unless work_permit.attached?
    errors.add(:work_permit_expires_on, "doit être renseigné") if work_permit_expires_on.blank?
  end

  def contract_requirements
    if manual_upload?
      errors.add(:signed_contract, "doit être fourni") unless signed_contract.attached?
    else
      errors.add(:contract_accepted, "doit être accepté") unless contract_accepted
    end
  end

  def phone_e164_for_country
    return if phone.blank? || residence_country.blank?

    parsed = Phonelib.parse(phone, residence_country)
    unless parsed.valid?
      errors.add(:phone, "doit être au format international E.164 et correspondre au pays de résidence")
    end
  end

  def normalize_phone_e164
    return if phone.blank? || residence_country.blank?

    parsed = Phonelib.parse(phone, residence_country)
    self.phone = parsed.e164 if parsed.valid?
  end

  def set_submitted_at
    self.submitted_at ||= Time.current
  end
end
