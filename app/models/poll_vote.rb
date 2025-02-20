# frozen_string_literal: true

# == Schema Information
#
# Table name: poll_votes
#
#  id         :bigint(8)        not null, primary key
#  choice     :integer          default(0), not null
#  uri        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#  poll_id    :bigint(8)        not null
#

class PollVote < ApplicationRecord
  belongs_to :account
  belongs_to :poll, inverse_of: :votes

  validates :choice, presence: true
  validates_with VoteValidator

  after_create_commit :increment_counter_cache

  delegate :local?, to: :account
  delegate :multiple?, :expired?, to: :poll, prefix: true

  # @rbs () -> void
  def object_type
    :vote
  end

  private

  # @rbs () -> bool
  def increment_counter_cache
    poll.cached_tallies[choice] = (poll.cached_tallies[choice] || 0) + 1
    poll.save
  rescue ActiveRecord::StaleObjectError
    poll.reload
    retry
  end
end
