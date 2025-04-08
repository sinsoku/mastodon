# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  # @rbs () -> (bool | String | Form::AdminSettings | ActiveSupport::SafeBuffer | Form::CustomEmojiBatch | CustomEmoji | AccountAlias | Integer | Admin::StatusBatchAction | Status | Trends::TagBatch | Form::AccountBatch | IpBlock | Form::IpBlockBatch | Appeal | Time | Array[untyped] | Symbol | Trends::PreviewCardProviderBatch | AccountRelationshipSeveranceEvent::ActiveRecord_Relation | Rule | AccountWarningPreset | Trends::PreviewCardBatch | Account::ActiveRecord_Relation | User | RQRCode::QRCode | Form::EmailDomainBlockBatch | EmailDomainBlock | Invite | Doorkeeper::Application | Doorkeeper::Application::ActiveRecord_AssociationRelation | Report::ActiveRecord_Relation | Status::ActiveRecord_Relation | Form::Redirect | DomainBlock | Form::Import | DomainAllow | AccountWarningPreset::ActiveRecord_Relation | Trends::StatusBatch | LoginActivity::ActiveRecord_Relation | Backup::ActiveRecord_Associations_CollectionProxy | UserRole | UserRole::ActiveRecord_Relation | AccountMigration | Tag::ActiveRecord_Relation | Range[untyped] | Form::TwoFactorConfirmation | Admin::ActionLog::ActiveRecord_Relation | Webhook | Webhook::ActiveRecord_Relation | Form::DeleteConfirmation | ActiveRecord::Promise::Complete | Announcement | FeaturedTag | CustomFilter::ActiveRecord_AssociationRelation | Form::StatusFilterBatchAction | CustomFilterKeyword | Relay | Relay::ActiveRecord_Relation | Appeal::ActiveRecord_Relation)?
  def set_locale(&block)
    I18n.with_locale(requested_locale || I18n.default_locale, &block)
  end

  private

  # @rbs () -> (String | Symbol)?
  def requested_locale
    requested_locale_name   = available_locale_or_nil(params[:lang])
    requested_locale_name ||= available_locale_or_nil(current_user.locale) if respond_to?(:user_signed_in?) && user_signed_in?
    requested_locale_name ||= http_accept_language if ENV['DEFAULT_LOCALE'].blank?
    requested_locale_name
  end

  # @rbs () -> String?
  def http_accept_language
    HttpAcceptLanguage::Parser.new(request.headers.fetch('Accept-Language')).language_region_compatible_from(I18n.available_locales) if request.headers.key?('Accept-Language')
  end

  # @rbs (String?) -> Symbol?
  def available_locale_or_nil(locale_name)
    locale_name.to_sym if locale_name.present? && I18n.available_locales.include?(locale_name.to_sym)
  end

  # @rbs () -> String
  def content_locale
    @content_locale ||= I18n.locale.to_s.split(/[_-]/).first
  end
end
