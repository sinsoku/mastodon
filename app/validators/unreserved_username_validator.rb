# frozen_string_literal: true

class UnreservedUsernameValidator < ActiveModel::Validator
  # @rbs (Account | untyped) -> ActiveModel::Error?
  def validate(account)
    @username = account.username

    return if @username.blank?

    account.errors.add(:username, :reserved) if reserved_username?
  end

  private

  # @rbs () -> void
  def reserved_username?
    pam_username_reserved? || settings_username_reserved?
  end

  # @rbs () -> void
  def pam_username_reserved?
    pam_controlled? && pam_reserves_username?
  end

  # @rbs () -> void
  def pam_controlled?
    Devise.pam_authentication && Devise.pam_controlled_service
  end

  # @rbs () -> void
  def pam_reserves_username?
    Rpam2.account(Devise.pam_controlled_service, @username)
  end

  # @rbs () -> void
  def settings_username_reserved?
    settings_has_reserved_usernames? && settings_reserves_username?
  end

  # @rbs () -> void
  def settings_has_reserved_usernames?
    Setting.reserved_usernames.present?
  end

  # @rbs () -> void
  def settings_reserves_username?
    Setting.reserved_usernames.include?(@username.downcase)
  end
end
