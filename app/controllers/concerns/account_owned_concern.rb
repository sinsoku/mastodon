# frozen_string_literal: true

module AccountOwnedConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, if: -> { limited_federation_mode? && request.format != :json }
    before_action :set_account, if: :account_required?
    before_action :check_account_approval, if: :account_required?
    before_action :check_account_suspension, if: :account_required?
    before_action :check_account_confirmation, if: :account_required?
  end

  private

  # @rbs () -> bool
  def account_required?
    true
  end

  # @rbs () -> Account
  def set_account
    @account = Account.find_local!(username_param)
  end

  # @rbs () -> void
  def username_param
    params[:account_username]
  end

  # @rbs () -> (ActiveSupport::SafeBuffer | String)?
  def check_account_approval
    not_found if @account.local? && @account.user_pending?
  end

  # @rbs () -> String?
  def check_account_confirmation
    not_found if @account.local? && !@account.user_confirmed?
  end

  # @rbs () -> (String | ActiveSupport::SafeBuffer)?
  def check_account_suspension
    if @account.permanently_unavailable?
      permanent_unavailability_response
    elsif @account.suspended? && !skip_temporary_suspension_response?
      temporary_suspension_response
    end
  end

  # @rbs () -> bool
  def skip_temporary_suspension_response?
    false
  end

  # @rbs () -> void
  def permanent_unavailability_response
    expires_in(3.minutes, public: true)
    gone
  end

  # @rbs () -> void
  def temporary_suspension_response
    expires_in(3.minutes, public: true)
    forbidden
  end
end
