# frozen_string_literal: true

module Settings
  module Exports
    class ListsController < BaseController
      include Settings::ExportControllerConcern

      # @rbs () -> String
      def index
        send_export_file
      end

      private

      # @rbs () -> String
      def export_data
        @export.to_lists_csv
      end
    end
  end
end
