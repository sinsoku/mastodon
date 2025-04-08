# frozen_string_literal: true

module RoutingHelper
  extend ActiveSupport::Concern

  include ActionView::Helpers::AssetTagHelper
  include Webpacker::Helper

  included do
    include Rails.application.routes.url_helpers

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  # @rbs (String, **nil | bool) -> String
  def full_asset_url(source, **options)
    source = ActionController::Base.helpers.asset_url(source, **options) unless use_storage?

    URI.join(asset_host, source).to_s
  end

  # @rbs () -> String
  def asset_host
    Rails.configuration.action_controller.asset_host || root_url
  end

  # @rbs (String, **nil) -> String
  def frontend_asset_path(source, **options)
    asset_pack_path("media/#{source}", **options)
  end

  # @rbs (String, **nil) -> String
  def frontend_asset_url(source, **options)
    full_asset_url(frontend_asset_path(source, **options))
  end

  # @rbs () -> bool
  def use_storage?
    Rails.configuration.x.use_s3 || Rails.configuration.x.use_swift
  end
end
