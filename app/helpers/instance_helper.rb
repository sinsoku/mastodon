# frozen_string_literal: true

module InstanceHelper
  # @rbs () -> String
  def site_title
    Setting.site_title
  end

  # @rbs () -> String
  def site_hostname
    @site_hostname ||= Addressable::URI.parse("//#{Rails.configuration.x.local_domain}").display_uri.host
  end

  # @rbs (?Invite?) -> ActiveSupport::SafeBuffer
  def description_for_sign_up(invite = nil)
    safe_join([description_prefix(invite), I18n.t('auth.description.suffix')], ' ')
  end

  # @rbs () -> InstancePresenter
  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end

  # @rbs (?Integer | String) -> String?
  def favicon_path(size = '48')
    instance_presenter.favicon&.file&.url(size)
  end

  # @rbs (?Integer | String) -> String?
  def app_icon_path(size = '48')
    instance_presenter.app_icon&.file&.url(size)
  end

  # @rbs () -> bool
  def use_mask_icon?
    instance_presenter.app_icon.blank?
  end

  private

  # @rbs (Invite?) -> String
  def description_prefix(invite)
    if invite.present?
      I18n.t('auth.description.prefix_invited_by_user', name: invite.user.account.username)
    else
      I18n.t('auth.description.prefix_sign_up')
    end
  end
end
