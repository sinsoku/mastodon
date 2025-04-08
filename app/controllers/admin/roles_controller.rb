# frozen_string_literal: true

module Admin
  class RolesController < BaseController
    before_action :set_role, except: [:index, :new, :create]

    # @rbs () -> UserRole::ActiveRecord_Relation?
    def index
      authorize :user_role, :index?

      @roles = UserRole.order(position: :desc).page(params[:page])
    end

    # @rbs () -> UserRole?
    def new
      authorize :user_role, :create?

      @role = UserRole.new
    end

    # @rbs () -> UserRole?
    def edit
      authorize @role, :update?
    end

    # @rbs () -> (String | ActiveSupport::SafeBuffer)
    def create
      authorize :user_role, :create?

      @role = UserRole.new(resource_params)
      @role.current_account = current_account

      if @role.save
        log_action :create, @role
        redirect_to admin_roles_path
      else
        render :new
      end
    end

    # @rbs () -> (ActiveSupport::SafeBuffer | String)?
    def update
      authorize @role, :update?

      @role.current_account = current_account

      if @role.update(resource_params)
        log_action :update, @role
        redirect_to admin_roles_path
      else
        render :edit
      end
    end

    # @rbs () -> String?
    def destroy
      authorize @role, :destroy?
      @role.destroy!
      log_action :destroy, @role
      redirect_to admin_roles_path
    end

    private

    # @rbs () -> UserRole
    def set_role
      @role = UserRole.find(params[:id])
    end

    # @rbs () -> ActionController::Parameters
    def resource_params
      params.require(:user_role).permit(:name, :color, :highlighted, :position, permissions_as_keys: [])
    end
  end
end
