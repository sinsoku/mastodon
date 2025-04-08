# frozen_string_literal: true

class PollPolicy < ApplicationPolicy
  # @rbs () -> bool
  def vote?
    StatusPolicy.new(current_account, record.status).show? && !current_account.blocking?(record.account) && !record.account.blocking?(current_account)
  end
end
