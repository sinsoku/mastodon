# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:view_dashboard)
  end
end
