# frozen_string_literal: true

class AppealPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_appeals)
  end

  # @rbs () -> bool
  def approve?
    record.pending? && role.can?(:manage_appeals)
  end

  # @rbs () -> bool
  def reject?
    record.pending? && role.can?(:manage_appeals)
  end
end
