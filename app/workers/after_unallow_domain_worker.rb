# frozen_string_literal: true

class AfterUnallowDomainWorker
  include Sidekiq::Worker

  # @rbs (String) -> nil
  def perform(domain)
    AfterUnallowDomainService.new.call(domain)
  end
end
