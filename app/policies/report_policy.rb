# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  # @rbs () -> bool
  def update?
    role.can?(:manage_reports)
  end

  # @rbs () -> bool
  def index?
    role.can?(:manage_reports)
  end

  # @rbs () -> bool
  def show?
    role.can?(:manage_reports)
  end
end
