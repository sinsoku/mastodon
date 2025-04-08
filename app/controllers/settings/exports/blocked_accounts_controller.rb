# frozen_string_literal: true

module Settings
  module Exports
    class BlockedAccountsController < BaseController
      include Settings::ExportControllerConcern

      # @rbs () -> String
      def index
        send_export_file
      end

      private

      # @rbs () -> String
      def export_data
        @export.to_blocked_accounts_csv
      end
    end
  end
end
