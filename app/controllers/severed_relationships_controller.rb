# frozen_string_literal: true

class SeveredRelationshipsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_cache_headers

  before_action :set_event, only: [:following, :followers]

  # @rbs () -> ActiveRecord::Relation
  def index
    @events = AccountRelationshipSeveranceEvent.where(account: current_account)
  end

  # @rbs () -> String
  def following
    respond_to do |format|
      format.csv { send_data following_data, filename: "following-#{@event.target_name}-#{@event.created_at.to_date.iso8601}.csv" }
    end
  end

  # @rbs () -> String
  def followers
    respond_to do |format|
      format.csv { send_data followers_data, filename: "followers-#{@event.target_name}-#{@event.created_at.to_date.iso8601}.csv" }
    end
  end

  private

  # @rbs () -> AccountRelationshipSeveranceEvent
  def set_event
    @event = AccountRelationshipSeveranceEvent.find(params[:id])
  end

  # @rbs () -> void
  def following_data
    CSV.generate(headers: ['Account address', 'Show boosts', 'Notify on new posts', 'Languages'], write_headers: true) do |csv|
      @event.severed_relationships.active.about_local_account(current_account).includes(:remote_account).reorder(id: :desc).each do |follow|
        csv << [acct(follow.target_account), follow.show_reblogs, follow.notify, follow.languages&.join(', ')]
      end
    end
  end

  # @rbs () -> void
  def followers_data
    CSV.generate(headers: ['Account address'], write_headers: true) do |csv|
      @event.severed_relationships.passive.about_local_account(current_account).includes(:remote_account).reorder(id: :desc).each do |follow|
        csv << [acct(follow.account)]
      end
    end
  end

  def acct(account)
    account.local? ? account.local_username_and_domain : account.acct
  end

  # @rbs () -> Hash[untyped, untyped]
  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
