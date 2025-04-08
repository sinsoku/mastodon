# frozen_string_literal: true

module Admin
  class RulesController < BaseController
    before_action :set_rule, except: [:index, :create]

    # @rbs () -> Rule
    def index
      authorize :rule, :index?

      @rules = Rule.ordered
      @rule  = Rule.new
    end

    # @rbs () -> Rule
    def edit
      authorize @rule, :update?
    end

    # @rbs () -> (ActiveSupport::SafeBuffer | String)
    def create
      authorize :rule, :create?

      @rule = Rule.new(resource_params)

      if @rule.save
        redirect_to admin_rules_path
      else
        @rules = Rule.ordered
        render :index
      end
    end

    # @rbs () -> (ActiveSupport::SafeBuffer | String)
    def update
      authorize @rule, :update?

      if @rule.update(resource_params)
        redirect_to admin_rules_path
      else
        render :edit
      end
    end

    # @rbs () -> String
    def destroy
      authorize @rule, :destroy?

      @rule.discard

      redirect_to admin_rules_path
    end

    private

    # @rbs () -> Rule
    def set_rule
      @rule = Rule.find(params[:id])
    end

    # @rbs () -> ActionController::Parameters
    def resource_params
      params.require(:rule).permit(:text, :hint, :priority)
    end
  end
end
