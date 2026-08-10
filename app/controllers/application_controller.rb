# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rate_limit to: 30, within: 1.minute
  rate_limit to: 500, within: 1.day

  def route_not_found
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def authenticate_admin_user!
    authenticate_user!
    return if current_user&.admin?

    respond_to do |format|
      format.html { redirect_to new_user_session_path, alert: "Du hast keinen Zugriff auf den Adminbereich." }
      format.json { render json: {errors: ["Kein Zugriff auf den Adminbereich"]}, status: :forbidden }
    end
  end
end
