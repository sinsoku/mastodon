# frozen_string_literal: true

module Admin
  class SiteUploadsController < BaseController
    before_action :set_site_upload

    # @rbs () -> String
    def destroy
      authorize :settings, :destroy?

      @site_upload.destroy!

      redirect_back fallback_location: admin_settings_path, notice: I18n.t('admin.site_uploads.destroyed_msg')
    end

    private

    # @rbs () -> SiteUpload
    def set_site_upload
      @site_upload = SiteUpload.find(params[:id])
    end
  end
end
