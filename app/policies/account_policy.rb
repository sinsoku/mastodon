# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_users)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_users)
  end

  # @rbs () -> bool
  def warn?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  # @rbs () -> bool
  def suspend?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role) && !record.instance_actor?
  end

  # @rbs () -> bool
  def destroy?
    record.suspended_temporarily? && role.can?(:delete_user_data)
  end

  # @rbs () -> bool
  def unsuspend?
    role.can?(:manage_users) && record.suspension_origin_local?
  end

  # @rbs () -> bool
  def sensitive?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  # @rbs () -> bool
  def unsensitive?
    role.can?(:manage_users)
  end

  # @rbs () -> bool
  def silence?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  # @rbs () -> bool
  def unsilence?
    role.can?(:manage_users)
  end

  # @rbs () -> bool
  def redownload?
    role.can?(:manage_federation)
  end

  # @rbs () -> bool
  def remove_avatar?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  # @rbs () -> bool
  def remove_header?
    role.can?(:manage_users, :manage_reports) && role.overrides?(record.user_role)
  end

  # @rbs () -> bool
  def memorialize?
    role.can?(:delete_user_data) && role.overrides?(record.user_role) && !record.instance_actor?
  end

  # @rbs () -> bool
  def unblock_email?
    role.can?(:manage_users)
  end

  # @rbs () -> bool
  def review?
    role.can?(:manage_taxonomies)
  end
end
