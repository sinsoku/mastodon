# frozen_string_literal: true

class ClearDomainMediaService < BaseService
  attr_reader :domain_block

  # @rbs (DomainBlock) -> nil
  def call(domain_block)
    @domain_block = domain_block
    clear_media! if domain_block.reject_media?
  end

  private

  # @rbs () -> nil
  def clear_media!
    clear_account_images!
    clear_account_attachments!
    clear_emojos!
  end

  # @rbs () -> void
  def clear_account_images!
    blocked_domain_accounts.reorder(nil).find_in_batches do |accounts|
      AttachmentBatch.new(Account, accounts).clear
    end
  end

  # @rbs () -> void
  def clear_account_attachments!
    media_from_blocked_domain.reorder(nil).find_in_batches do |attachments|
      AttachmentBatch.new(MediaAttachment, attachments).clear
    end
  end

  # @rbs () -> nil
  def clear_emojos!
    emojis_from_blocked_domains.find_in_batches do |custom_emojis|
      AttachmentBatch.new(CustomEmoji, custom_emojis).delete
    end
  end

  # @rbs () -> String
  def blocked_domain
    domain_block.domain
  end

  # @rbs () -> Account::ActiveRecord_Relation
  def blocked_domain_accounts
    Account.by_domain_and_subdomains(blocked_domain)
  end

  # @rbs () -> MediaAttachment::ActiveRecord_Relation
  def media_from_blocked_domain
    MediaAttachment.joins(:account).merge(blocked_domain_accounts)
  end

  # @rbs () -> CustomEmoji::ActiveRecord_Relation
  def emojis_from_blocked_domains
    CustomEmoji.by_domain_and_subdomains(blocked_domain)
  end
end
