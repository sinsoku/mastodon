# frozen_string_literal: true

class AfterUnallowDomainWorker
  include Sidekiq::Worker

  # @rbs (String) -> void
  def perform(domain)
    AfterUnallowDomainService.new.call(domain)
  end
end
