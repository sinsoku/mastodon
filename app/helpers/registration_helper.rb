# frozen_string_literal: true

module RegistrationHelper
  extend ActiveSupport::Concern

  # @rbs (String | IPAddr, Invite?) -> bool?
  def allowed_registration?(remote_ip, invite)
    !Rails.configuration.x.single_user_mode && !omniauth_only? && (registrations_open? || invite&.valid_for_use?) && !ip_blocked?(remote_ip)
  end

  # @rbs () -> bool
  def registrations_open?
    Setting.registrations_mode != 'none'
  end

  # @rbs () -> bool
  def omniauth_only?
    ENV['OMNIAUTH_ONLY'] == 'true'
  end

  # @rbs (String | IPAddr) -> bool
  def ip_blocked?(remote_ip)
    IpBlock.where(severity: :sign_up_block).exists?(['ip >>= ?', remote_ip.to_s])
  end
end
