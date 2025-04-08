# frozen_string_literal: true

module Admin
  class InvitesController < BaseController
    # @rbs () -> Invite
    def index
      authorize :invite, :index?

      @invites = filtered_invites.includes(user: :account).page(params[:page])
      @invite  = Invite.new
    end

    # @rbs () -> String
    def create
      authorize :invite, :create?

      @invite      = Invite.new(resource_params)
      @invite.user = current_user

      if @invite.save
        redirect_to admin_invites_path
      else
        @invites = Invite.page(params[:page])
        render :index
      end
    end

    # @rbs () -> String
    def destroy
      @invite = Invite.find(params[:id])
      authorize @invite, :destroy?
      @invite.expire!
      redirect_to admin_invites_path
    end

    # @rbs () -> String
    def deactivate_all
      authorize :invite, :deactivate_all?
      Invite.available.in_batches.update_all(expires_at: Time.now.utc)
      redirect_to admin_invites_path
    end

    private

    # @rbs () -> ActionController::Parameters
    def resource_params
      params.require(:invite).permit(:max_uses, :expires_in)
    end

    # @rbs () -> Invite::ActiveRecord_Relation
    def filtered_invites
      InviteFilter.new(filter_params).results
    end

    # @rbs () -> ActionController::Parameters
    def filter_params
      params.slice(*InviteFilter::KEYS).permit(*InviteFilter::KEYS)
    end
  end
end
