# frozen_string_literal: true

# == Schema Information
#
# Table name: webhooks
#
#  id         :bigint(8)        not null, primary key
#  url        :string           not null
#  events     :string           default([]), not null, is an Array
#  secret     :string           default(""), not null
#  enabled    :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  template   :text
#

class Webhook < ApplicationRecord
  EVENTS = %w(
    account.approved
    account.created
    account.updated
    report.created
    report.updated
    status.created
    status.updated
  ).freeze

  attr_writer :current_account

  scope :enabled, -> { where(enabled: true) }

  validates :url, presence: true, url: true
  validates :secret, presence: true, length: { minimum: 12 }
  validates :events, presence: true

  validate :events_validation_error, if: :invalid_events?
  validate :validate_permissions
  validate :validate_template

  normalizes :events, with: ->(events) { events.filter_map { |event| event.strip.presence } }
  before_validation :generate_secret

  # @rbs () -> void
  def rotate_secret!
    update!(secret: SecureRandom.hex(20))
  end

  # @rbs () -> void
  def enable!
    update!(enabled: true)
  end

  # @rbs () -> void
  def disable!
    update!(enabled: false)
  end

  # @rbs () -> (Array[untyped] | void)
  def required_permissions
    events.map { |event| Webhook.permission_for_event(event) }.uniq
  end

  # @rbs (String?) -> (void | Symbol)
  def self.permission_for_event(event)
    case event
    when 'account.approved', 'account.created', 'account.updated'
      :manage_users
    when 'report.created', 'report.updated'
      :manage_reports
    when 'status.created', 'status.updated'
      :view_devops
    end
  end

  private

  # @rbs () -> ActiveModel::Error
  def events_validation_error
    errors.add(:events, :invalid)
  end

  # @rbs () -> bool
  def invalid_events?
    events.blank? || events.difference(EVENTS).any?
  end

  # @rbs () -> ActiveModel::Error?
  def validate_permissions
    errors.add(:events, :invalid_permissions) if defined?(@current_account) && required_permissions.any? { |permission| !@current_account.user_role.can?(permission) }
  end

  # @rbs () -> ActiveModel::Error?
  def validate_template
    return if template.blank?

    begin
      parser = Webhooks::PayloadRenderer::TemplateParser.new
      parser.parse(template)
    rescue Parslet::ParseFailed
      errors.add(:template, :invalid)
    end
  end

  # @rbs () -> String?
  def generate_secret
    self.secret = SecureRandom.hex(20) if secret.blank?
  end
end
