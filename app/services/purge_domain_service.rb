# frozen_string_literal: true

class PurgeDomainService < BaseService
  # @rbs (String) -> void
  def call(domain)
    @domain = domain

    purge_relationship_severance_events!
    purge_accounts!
    purge_emojis!

    Instance.refresh
  end

  # @rbs () -> void
  def purge_relationship_severance_events!
    RelationshipSeveranceEvent.where(type: [:domain_block, :user_domain_block], target_name: @domain).in_batches.update_all(purged: true)
  end

  # @rbs () -> void
  def purge_accounts!
    Account.remote.where(domain: @domain).find_each do |account|
      DeleteAccountService.new.call(account, reserve_username: false, skip_side_effects: true)
    end
  end

  # @rbs () -> void
  def purge_emojis!
    CustomEmoji.remote.where(domain: @domain).find_each(&:destroy)
  end
end
