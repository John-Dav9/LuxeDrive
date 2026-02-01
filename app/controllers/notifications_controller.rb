class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc).limit(50)

    respond_to do |format|
      format.html
      format.json do
        latest = current_user.notifications.order(created_at: :desc).first
        render json: {
          unread_count: current_user.notifications.unread.count,
          latest: latest ? { id: latest.id, title: latest.title, body: latest.body } : nil
        }
      end
    end
  end

  def read
    notification = current_user.notifications.find(params[:id])
    notification.mark_read!
    redirect_to notifications_path
  end
end
