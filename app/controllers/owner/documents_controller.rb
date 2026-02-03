class Owner::DocumentsController < Owner::BaseController
  require "zip"
  def index
    @owner_request = current_user.owner_request
    render "owner/documents_index"
  end

  def download_all
    owner_request = current_user.owner_request
    return redirect_to owner_documents_path, alert: "Aucun dossier trouvé." if owner_request.blank?

    attachments = documents_for(owner_request)
    return redirect_to owner_documents_path, alert: "Aucun document disponible." if attachments.empty?

    zip_data = Zip::OutputStream.write_buffer do |zip|
      attachments.each do |label, attachment|
        next unless attachment.attached?

        filename = "#{label}-#{attachment.filename}"
        zip.put_next_entry(filename)
        zip.write(attachment.blob.download)
      end
    end

    zip_data.rewind
    send_data zip_data.read,
              filename: "documents_prestataire_#{current_user.id}.zip",
              type: "application/zip"
  end

  private

  def documents_for(owner_request)
    {
      "piece_identite" => owner_request.id_document,
      "permis_conduire" => owner_request.driver_license,
      "justificatif_domicile" => owner_request.proof_of_address,
      "rib" => owner_request.bank_rib,
      "selfie" => owner_request.selfie,
      "permis_travail" => owner_request.work_permit,
      "contrat_signe" => owner_request.signed_contract
    }
  end
end
