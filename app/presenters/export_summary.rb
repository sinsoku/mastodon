# frozen_string_literal: true

class ExportSummary
  attr_reader :account, :counts

  delegate(
    :blocking,
    :bookmarks,
    :domain_blocks,
    :owned_lists,
    :media_attachments,
    :muting,
    to: :account,
    prefix: true
  )

  # @rbs (Account) -> void
  def initialize(account)
    @account = account
    @counts = populate_counts
  end

  # @rbs () -> void
  def total_blocks
    counts[:blocks].value
  end

  # @rbs () -> void
  def total_bookmarks
    counts[:bookmarks].value
  end

  # @rbs () -> void
  def total_domain_blocks
    counts[:domain_blocks].value
  end

  # @rbs () -> void
  def total_followers
    account.followers_count
  end

  # @rbs () -> void
  def total_follows
    account.following_count
  end

  # @rbs () -> void
  def total_lists
    counts[:owned_lists].value
  end

  # @rbs () -> void
  def total_mutes
    counts[:muting].value
  end

  # @rbs () -> void
  def total_statuses
    account.statuses_count
  end

  # @rbs () -> void
  def total_storage
    counts[:storage].value
  end

  private

  # @rbs () -> Hash[untyped, untyped]
  def populate_counts
    {
      blocks: account_blocking.async_count,
      bookmarks: account_bookmarks.async_count,
      domain_blocks: account_domain_blocks.async_count,
      owned_lists: account_owned_lists.async_count,
      muting: account_muting.async_count,
      storage: account_media_attachments.async_sum(:file_file_size),
    }
  end
end
