# frozen_string_literal: true

class URLValidator < ActiveModel::EachValidator
  VALID_SCHEMES = %w(http https).freeze

  # @rbs (PreviewCard | Webhook | Relay | Doorkeeper::Application | Web::PushSubscription, Symbol, String?) -> ActiveModel::Error?
  def validate_each(record, attribute, value)
    @value = value

    record.errors.add(attribute, :invalid) unless compliant_url?
  end

  private

  # @rbs () -> bool
  def compliant_url?
    parsed_url.present? && valid_url_scheme? && valid_url_host?
  end

  # @rbs () -> (Addressable::URI | bool)?
  def parsed_url
    Addressable::URI.parse(@value)
  rescue Addressable::URI::InvalidURIError
    false
  end

  # @rbs () -> bool
  def valid_url_scheme?
    VALID_SCHEMES.include?(parsed_url.scheme)
  end

  # @rbs () -> bool
  def valid_url_host?
    parsed_url.host.present?
  end
end
