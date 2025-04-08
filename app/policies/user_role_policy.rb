# frozen_string_literal: true

class UserRolePolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_roles)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_roles)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_roles) && (role.overrides?(record) || role.id == record.id)
  end

  # @rbs () -> bool
  def destroy?
    !record.everyone? && role.can?(:manage_roles) && role.overrides?(record) && role.id != record.id
  end
end
