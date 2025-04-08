# frozen_string_literal: true

class SoftwareUpdatePolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:view_devops)
  end
end
