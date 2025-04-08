# frozen_string_literal: true

class RelationshipsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_accounts, only: :show
  before_action :set_relationships, only: :show
  before_action :set_cache_headers

  helper_method :following_relationship?, :followed_by_relationship?, :mutual_relationship?

  # @rbs () -> Form::AccountBatch
  def show
    @form = Form::AccountBatch.new
  end

  # @rbs () -> nil
  def update
    @form = Form::AccountBatch.new(form_account_batch_params.merge(current_account: current_account, action: action_from_button))
    @form.save
  rescue ActionController::ParameterMissing
    # Do nothing
  rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound
    flash[:alert] = I18n.t('relationships.follow_failure') if action_from_button == 'follow'
  ensure
    redirect_to relationships_path(filter_params)
  end

  private

  # @rbs () -> Account::ActiveRecord_AssociationRelation
  def set_accounts
    @accounts = RelationshipFilter.new(current_account, filter_params).results.page(params[:page]).per(40)
  end

  # @rbs () -> AccountRelationshipsPresenter
  def set_relationships
    @relationships = AccountRelationshipsPresenter.new(@accounts, current_user.account_id)
  end

  # @rbs () -> ActionController::Parameters?
  def form_account_batch_params
    params.require(:form_account_batch).permit(:action, account_ids: [])
  end

  # @rbs () -> bool
  def following_relationship?
    params[:relationship].blank? || params[:relationship] == 'following'
  end

  # @rbs () -> bool
  def mutual_relationship?
    params[:relationship] == 'mutual'
  end

  # @rbs () -> bool
  def followed_by_relationship?
    params[:relationship] == 'followed_by'
  end

  # @rbs () -> ActionController::Parameters
  def filter_params
    params.slice(:page, *RelationshipFilter::KEYS).permit(:page, *RelationshipFilter::KEYS)
  end

  # @rbs () -> String
  def action_from_button
    if params[:follow]
      'follow'
    elsif params[:unfollow]
      'unfollow'
    elsif params[:remove_from_followers]
      'remove_from_followers'
    elsif params[:block_domains] || params[:remove_domains_from_followers]
      'remove_domains_from_followers'
    end
  end

  # @rbs () -> Hash[untyped, untyped]
  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
