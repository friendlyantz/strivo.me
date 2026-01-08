Rails.application.config.session_store :cookie_store,
  key: "_strivo_me_session",
  expire_after: 8.days,  # Session expires after inactivity
  secure: Rails.env.production?,  # Only send over HTTPS in production
  httponly: true,  # Prevent JavaScript access
  same_site: :lax  # CSRF protection
