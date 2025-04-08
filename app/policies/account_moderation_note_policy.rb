# frozen_string_literal: true

class AccountModerationNotePolicy < ApplicationPolicy
  # @rbs () -> bool
  def create?
    role.can?(:manage_reports)
  end

  # @rbs () -> bool
  def destroy?
    owner? || (role.can?(:manage_reports) && role.overrides?(record.account.user_role))
  end

  private

  # @rbs () -> bool
  def owner?
    record.account_id == current_account&.id
  end
end
