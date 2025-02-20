# frozen_string_literal: true

module Admin
  class ActionLogsController < BaseController
    before_action :set_action_logs

    # @rbs () -> ActiveRecord::Relation
    def index
      authorize :audit_log, :index?
      @auditable_accounts = Account.auditable.select(:id, :username)
    end

    private

    # @rbs () -> ActiveRecord::Relation
    def set_action_logs
      @action_logs = Admin::ActionLogFilter.new(filter_params).results.page(params[:page])
    end

    # @rbs () -> void
    def filter_params
      params.slice(:page, *Admin::ActionLogFilter::KEYS).permit(:page, *Admin::ActionLogFilter::KEYS)
    end
  end
end
