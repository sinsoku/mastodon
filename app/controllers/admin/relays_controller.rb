# frozen_string_literal: true

module Admin
  class RelaysController < BaseController
    before_action :set_relay, except: [:index, :new, :create]
    before_action :warn_signatures_not_enabled!, only: [:new, :create, :enable]

    # @rbs () -> ActiveRecord::Relation
    def index
      authorize :relay, :update?
      @relays = Relay.all
    end

    # @rbs () -> Relay
    def new
      authorize :relay, :update?
      @relay = Relay.new
    end

    # @rbs () -> (String | ActiveSupport::SafeBuffer)
    def create
      authorize :relay, :update?

      @relay = Relay.new(resource_params)

      if @relay.save
        log_action :create, @relay
        @relay.enable!
        redirect_to admin_relays_path
      else
        render :new
      end
    end

    # @rbs () -> String
    def destroy
      authorize :relay, :update?
      @relay.destroy
      log_action :destroy, @relay
      redirect_to admin_relays_path
    end

    # @rbs () -> String
    def enable
      authorize :relay, :update?
      @relay.enable!
      log_action :enable, @relay
      redirect_to admin_relays_path
    end

    # @rbs () -> String
    def disable
      authorize :relay, :update?
      @relay.disable!
      log_action :disable, @relay
      redirect_to admin_relays_path
    end

    private

    # @rbs () -> Relay
    def set_relay
      @relay = Relay.find(params[:id])
    end

    # @rbs () -> void
    def resource_params
      params.require(:relay).permit(:inbox_url)
    end

    # @rbs () -> nil
    def warn_signatures_not_enabled!
      flash.now[:error] = I18n.t('admin.relays.signatures_not_enabled') if authorized_fetch_mode?
    end
  end
end
