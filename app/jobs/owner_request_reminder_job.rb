class OwnerRequestReminderJob < ApplicationJob
  queue_as :default

  def perform
    OwnerRequest.where(status: %i[pending needs_contract]).find_each do |request|
      next unless request.incomplete? || request.documents_expiring_soon?

      Notification.create!(
        user: request.user,
        kind: "owner_request_reminder",
        title: "Votre dossier prestataire nécessite une action",
        body: "Merci de compléter votre dossier ou renouveler vos documents.",
        link_path: "/owner_request"
      )
      OwnerRequestMailer.user_reminder(request).deliver_now
      request.log_event!("reminder_sent", note: "auto")
    end
  end
end
