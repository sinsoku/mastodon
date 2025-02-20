# frozen_string_literal: true

module Admin
  class WebhooksController < BaseController
    before_action :set_webhook, except: [:index, :new, :create]

    # @rbs () -> ActiveRecord::Relation
    def index
      authorize :webhook, :index?

      @webhooks = Webhook.page(params[:page])
    end

    # @rbs () -> Webhook
    def show
      authorize @webhook, :show?
    end

    # @rbs () -> Webhook
    def new
      authorize :webhook, :create?

      @webhook = Webhook.new
    end

    # @rbs () -> Webhook
    def edit
      authorize @webhook, :update?
    end

    # @rbs () -> (ActiveSupport::SafeBuffer | String)
    def create
      authorize :webhook, :create?

      @webhook = Webhook.new(resource_params)
      @webhook.current_account = current_account

      if @webhook.save
        redirect_to admin_webhook_path(@webhook)
      else
        render :new
      end
    end

    # @rbs () -> (ActiveSupport::SafeBuffer | String)
    def update
      authorize @webhook, :update?

      @webhook.current_account = current_account

      if @webhook.update(resource_params)
        redirect_to admin_webhook_path(@webhook)
      else
        render :edit
      end
    end

    # @rbs () -> String
    def enable
      authorize @webhook, :enable?
      @webhook.enable!
      redirect_to admin_webhook_path(@webhook)
    end

    # @rbs () -> String
    def disable
      authorize @webhook, :disable?
      @webhook.disable!
      redirect_to admin_webhook_path(@webhook)
    end

    # @rbs () -> String
    def destroy
      authorize @webhook, :destroy?
      @webhook.destroy!
      redirect_to admin_webhooks_path
    end

    private

    # @rbs () -> Webhook
    def set_webhook
      @webhook = Webhook.find(params[:id])
    end

    # @rbs () -> void
    def resource_params
      params.require(:webhook).permit(:url, :template, events: [])
    end
  end
end
