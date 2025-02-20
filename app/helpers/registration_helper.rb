# frozen_string_literal: true

module RegistrationHelper
  extend ActiveSupport::Concern

  # @rbs (String | IPAddr, Invite?) -> void
  def allowed_registration?(remote_ip, invite)
    !Rails.configuration.x.single_user_mode && !omniauth_only? && (registrations_open? || invite&.valid_for_use?) && !ip_blocked?(remote_ip)
  end

  # @rbs () -> void
  def registrations_open?
    Setting.registrations_mode != 'none'
  end

  # @rbs () -> (void | bool)
  def omniauth_only?
    ENV['OMNIAUTH_ONLY'] == 'true'
  end

  # @rbs (String | IPAddr) -> bool
  def ip_blocked?(remote_ip)
    IpBlock.severity_sign_up_block.containing(remote_ip.to_s).exists?
  end
end
