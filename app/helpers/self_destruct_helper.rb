# frozen_string_literal: true

module SelfDestructHelper
  # @rbs () -> bool
  def self.self_destruct?
    value = ENV.fetch('SELF_DESTRUCT', nil)
    value.present? && Rails.application.message_verifier('self-destruct').verify(value) == ENV['LOCAL_DOMAIN']
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    false
  end

  # @rbs () -> bool
  def self_destruct?
    SelfDestructHelper.self_destruct?
  end
end
