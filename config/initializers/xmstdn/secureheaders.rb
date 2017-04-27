# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      strict: true
    }
  }
  config.referrer_policy = 'origin-when-cross-origin'
  config.csp = SecureHeaders::OPT_OUT
end
