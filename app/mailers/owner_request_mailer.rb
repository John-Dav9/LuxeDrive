class OwnerRequestMailer < ApplicationMailer
  default from: "no-reply@luxedrive.com"

  def admin_new_request(admin, owner_request)
    @admin = admin
    @owner_request = owner_request
    mail(
      to: @admin.email,
      subject: "Nouvelle demande prestataire - #{owner_request.user.full_name}",
      body: <<~BODY,
        Bonjour #{@admin.full_name},

        Une nouvelle demande prestataire a été soumise par #{@owner_request.user.full_name}.

        Accéder au dossier : #{super_admin_owner_request_url(@owner_request)}

        LuxeDrive
      BODY
      content_type: "text/plain"
    )
  end

  def user_status_updated(owner_request)
    @owner_request = owner_request
    @user = owner_request.user
    mail(
      to: @user.email,
      subject: "Mise à jour de votre dossier prestataire",
      body: <<~BODY,
        Bonjour #{@user.full_name},

        Le statut de votre dossier prestataire est maintenant : #{@owner_request.status.humanize}.

        Vous pouvez consulter votre dossier ici : #{owner_request_url}

        LuxeDrive
      BODY
      content_type: "text/plain"
    )
  end

  def user_reminder(owner_request)
    @owner_request = owner_request
    @user = owner_request.user
    mail(
      to: @user.email,
      subject: "Action requise sur votre dossier prestataire",
      body: <<~BODY,
        Bonjour #{@user.full_name},

        Votre dossier prestataire nécessite une action (documents manquants ou expirant bientôt).

        Accéder à votre dossier : #{owner_request_url}

        LuxeDrive
      BODY
      content_type: "text/plain"
    )
  end

  def send_contract(owner_request, message = nil)
    @owner_request = owner_request
    @user = owner_request.user
    @message = message
    mail(
      to: @user.email,
      subject: "Contrat prestataire - LuxeDrive",
      body: <<~BODY,
        Bonjour #{@user.full_name},

        Votre contrat prestataire est disponible. Merci de le consulter et de le signer.

        Accéder au contrat : #{provider_contract_url}

        #{message.present? ? "Message du support : #{message}" : ""}

        LuxeDrive
      BODY
      content_type: "text/plain"
    )
  end
end
