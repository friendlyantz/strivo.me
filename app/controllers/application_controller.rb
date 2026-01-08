class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :likely_webview?

  private

  def likely_webview?
    ua = request.user_agent.to_s.downcase
    android_webview = ua.include?("wv")  # Android WebView Lollipop+
    ios_webview = /iphone|ipad|ipod/.match?(ua) && !/safari/.match?(ua)
    android_webview || ios_webview || cookies[:telegram_webview] == "true"
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session[:user_id] = nil
  end

  def current_user
    @current_user ||=
      if session[:user_id]
        User.find_by(id: session[:user_id])
      end
  end

  def require_current_user!
    redirect_to new_webauthn_session_path if current_user.blank?
  end
end
