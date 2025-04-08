# frozen_string_literal: true

class WebPushRequest
  SIGNATURE_ALGORITHM = 'p256ecdsa'
  AUTH_HEADER = 'WebPush'
  PAYLOAD_EXPIRATION = 24.hours
  JWT_ALGORITHM = 'ES256'
  JWT_TYPE = 'JWT'

  attr_reader :web_push_subscription

  delegate(
    :endpoint,
    :key_auth,
    :key_p256dh,
    to: :web_push_subscription
  )

  # @rbs (Web::PushSubscription) -> void
  def initialize(web_push_subscription)
    @web_push_subscription = web_push_subscription
  end

  # @rbs () -> String
  def audience
    @audience ||= Addressable::URI.parse(endpoint).normalized_site
  end

  # @rbs () -> String
  def authorization_header
    [AUTH_HEADER, encoded_json_web_token].join(' ')
  end

  # @rbs () -> String
  def crypto_key_header
    [SIGNATURE_ALGORITHM, vapid_key.public_key_for_push_header].join('=')
  end

  # @rbs (String) -> Hash[untyped, untyped]
  def encrypt(payload)
    Webpush::Encryption.encrypt(payload, key_p256dh, key_auth)
  end

  private

  # @rbs () -> String
  def encoded_json_web_token
    JWT.encode(
      web_token_payload,
      vapid_key.curve,
      JWT_ALGORITHM,
      typ: JWT_TYPE
    )
  end

  # @rbs () -> Hash[untyped, untyped]
  def web_token_payload
    {
      aud: audience,
      exp: PAYLOAD_EXPIRATION.from_now.to_i,
      sub: payload_subject,
    }
  end

  # @rbs () -> String
  def payload_subject
    [:mailto, contact_email].join(':')
  end

  # @rbs () -> Webpush::VapidKey
  def vapid_key
    @vapid_key ||= Webpush::VapidKey.from_keys(
      Rails.configuration.x.vapid_public_key,
      Rails.configuration.x.vapid_private_key
    )
  end

  # @rbs () -> String
  def contact_email
    @contact_email ||= ::Setting.site_contact_email
  end
end
