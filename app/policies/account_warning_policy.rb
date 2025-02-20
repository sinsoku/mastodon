# frozen_string_literal: true

class AccountWarningPolicy < ApplicationPolicy
  # @rbs () -> bool
  def show?
    target? || role.can?(:manage_appeals)
  end

  # @rbs () -> bool
  def appeal?
    target? && record.created_at >= Appeal::MAX_STRIKE_AGE.ago
  end

  private

  # @rbs () -> void
  def target?
    record.target_account_id == current_account&.id
  end
end
