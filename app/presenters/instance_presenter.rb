# frozen_string_literal: true

class InstancePresenter < ActiveModelSerializers::Model
  attributes :domain, :title, :version, :source_url,
             :description, :languages, :rules, :contact

  class ContactPresenter < ActiveModelSerializers::Model
    attributes :email, :account

    # @rbs () -> String
    def email
      Setting.site_contact_email
    end

    # @rbs () -> Account?
    def account
      username, domain = Setting.site_contact_username.strip.gsub(/\A@/, '').split('@', 2)
      domain = nil if TagManager.instance.local_domain?(domain)
      Account.find_remote(username, domain) if username.present?
    end
  end

  # @rbs () -> InstancePresenter::ContactPresenter
  def contact
    ContactPresenter.new
  end

  # @rbs () -> String
  def description
    Setting.site_short_description
  end

  # @rbs () -> String
  def extended_description
    Setting.site_extended_description
  end

  # @rbs () -> nil
  def status_page_url
    Setting.status_page_url
  end

  # @rbs () -> String
  def domain
    Rails.configuration.x.local_domain
  end

  # @rbs () -> String
  def title
    Setting.site_title
  end

  # @rbs () -> Array[untyped]
  def languages
    [I18n.default_locale]
  end

  # @rbs () -> Rule::ActiveRecord_Relation
  def rules
    Rule.ordered
  end

  # @rbs () -> Integer
  def user_count
    Rails.cache.fetch('user_count') { User.confirmed.joins(:account).merge(Account.without_suspended).count }
  end

  # @rbs (?Integer) -> Integer
  def active_user_count(num_weeks = 4)
    Rails.cache.fetch("active_user_count/#{num_weeks}") { ActivityTracker.new('activity:logins', :unique).sum(num_weeks.weeks.ago) }
  end

  # @rbs () -> Integer
  def status_count
    Rails.cache.fetch('local_status_count') { Account.local.joins(:account_stat).sum('account_stats.statuses_count') }.to_i
  end

  # @rbs () -> Integer
  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Instance.count }
  end

  # @rbs () -> String
  def version
    Mastodon::Version.to_s
  end

  # @rbs () -> String
  def source_url
    Mastodon::Version.source_url
  end

  # @rbs () -> SiteUpload?
  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail') { SiteUpload.find_by(var: 'thumbnail') }
  end

  # @rbs () -> SiteUpload?
  def mascot
    @mascot ||= Rails.cache.fetch('site_uploads/mascot') { SiteUpload.find_by(var: 'mascot') }
  end

  # @rbs () -> SiteUpload?
  def favicon
    return @favicon if defined?(@favicon)

    @favicon ||= Rails.cache.fetch('site_uploads/favicon') { SiteUpload.find_by(var: 'favicon') }
  end

  # @rbs () -> SiteUpload?
  def app_icon
    return @app_icon if defined?(@app_icon)

    @app_icon ||= Rails.cache.fetch('site_uploads/app_icon') { SiteUpload.find_by(var: 'app_icon') }
  end
end
