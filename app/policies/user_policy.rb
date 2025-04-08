# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # @rbs () -> bool
  def reset_password?
    role.can?(:manage_user_access) && role.overrides?(record.role)
  end

  # @rbs () -> bool
  def change_email?
    role.can?(:manage_user_access) && role.overrides?(record.role)
  end

  # @rbs () -> bool
  def disable_2fa?
    role.can?(:manage_user_access) && role.overrides?(record.role)
  end

  # @rbs () -> bool
  def change_role?
    role.can?(:manage_roles) && role.overrides?(record.role)
  end

  # @rbs () -> bool
  def confirm?
    role.can?(:manage_user_access) && !record.confirmed?
  end

  # @rbs () -> bool
  def enable?
    role.can?(:manage_users)
  end

  # @rbs () -> bool
  def approve?
    role.can?(:manage_users) && !record.approved?
  end

  # @rbs () -> bool
  def reject?
    role.can?(:manage_users) && !record.approved?
  end

  # @rbs () -> bool
  def disable?
    role.can?(:manage_users) && role.overrides?(record.role)
  end
end
