# frozen_string_literal: true

class InvitePolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_invites)
  end

  # @rbs () -> bool
  def create?
    role.can?(:invite_users)
  end

  # @rbs () -> bool
  def deactivate_all?
    role.can?(:manage_invites)
  end

  # @rbs () -> bool
  def destroy?
    owner? || role.can?(:manage_invites)
  end

  private

  # @rbs () -> bool
  def owner?
    record.user_id == current_user&.id
  end
end
