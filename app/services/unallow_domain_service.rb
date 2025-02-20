# frozen_string_literal: true

class UnallowDomainService < BaseService
  include DomainControlHelper

  # @rbs (DomainAllow) -> void
  def call(domain_allow)
    suspend_accounts!(domain_allow.domain) if limited_federation_mode?

    domain_allow.destroy
  end

  private

  # @rbs (String) -> void
  def suspend_accounts!(domain)
    Account.where(domain: domain).in_batches.touch_all(:suspended_at)
    AfterUnallowDomainWorker.perform_async(domain)
  end
end
