# frozen_string_literal: true

class AuditLogPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:view_audit_log)
  end
end
