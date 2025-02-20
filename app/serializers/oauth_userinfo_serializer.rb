# frozen_string_literal: true

class OauthUserinfoSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :iss, :sub, :name, :preferred_username, :profile, :picture

  # @rbs () -> String
  def iss
    root_url
  end

  # @rbs () -> String
  def sub
    ActivityPub::TagManager.instance.uri_for(object)
  end

  # @rbs () -> String
  def name
    object.display_name
  end

  # @rbs () -> String
  def preferred_username
    object.username
  end

  # @rbs () -> String
  def profile
    ActivityPub::TagManager.instance.url_for(object)
  end

  # @rbs () -> String
  def picture
    full_asset_url(object.avatar_original_url)
  end
end
