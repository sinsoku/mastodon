# frozen_string_literal: true

# == Schema Information
#
# Table name: email_domain_blocks
#
#  id                  :bigint(8)        not null, primary key
#  domain              :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  parent_id           :bigint(8)
#  allow_with_approval :boolean          default(FALSE), not null
#

class EmailDomainBlock < ApplicationRecord
  self.ignored_columns += %w(
    ips
    last_refresh_at
  )

  include DomainNormalizable
  include Paginable

  with_options class_name: 'EmailDomainBlock' do
    belongs_to :parent, optional: true
    has_many :children, foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy
  end

  validates :domain, presence: true, uniqueness: true, domain: true

  # Used for adding multiple blocks at once
  attr_accessor :other_domains

  # @rbs () -> String
  def to_log_human_identifier
    domain
  end

  # @rbs () -> Trends::History
  def history
    @history ||= Trends::History.new('email_domain_blocks', id)
  end

  class Matcher
    # @rbs (Array[untyped] | String, ?attempt_ip: nil | String | IPAddr) -> void
    def initialize(domain_or_domains, attempt_ip: nil)
      @uris       = extract_uris(domain_or_domains)
      @attempt_ip = attempt_ip
    end

    # @rbs (*untyped, **untyped) -> bool
    def match?(...)
      blocking?(...) || invalid_uri?
    end

    private

    # @rbs () -> bool
    def invalid_uri?
      @uris.any?(&:nil?)
    end

    # @rbs (?allow_with_approval: bool) -> bool
    def blocking?(allow_with_approval: false)
      blocks = EmailDomainBlock.where(domain: domains_with_variants, allow_with_approval: allow_with_approval).by_domain_length
      blocks.each { |block| block.history.add(@attempt_ip) } if @attempt_ip.present?
      blocks.any?
    end

    # @rbs () -> Array[untyped]
    def domains_with_variants
      @uris.flat_map do |uri|
        next if uri.nil?

        segments = uri.normalized_host.split('.')

        segments.map.with_index { |_, i| segments[i..].join('.') }
      end
    end

    # @rbs (Array[untyped] | String) -> Array[untyped]
    def extract_uris(domain_or_domains)
      Array(domain_or_domains).map do |str|
        domain = if str.include?('@')
                   str.split('@', 2).last
                 else
                   str
                 end

        Addressable::URI.new.tap { |u| u.host = domain.strip } if domain.present?
      rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
        nil
      end
    end
  end

  # @rbs (String | Array[untyped], ?attempt_ip: nil | String | IPAddr) -> bool
  def self.block?(domain_or_domains, attempt_ip: nil)
    Matcher.new(domain_or_domains, attempt_ip: attempt_ip).match?
  end

  # @rbs (Array[untyped], ?attempt_ip: nil | IPAddr) -> bool
  def self.requires_approval?(domain_or_domains, attempt_ip: nil)
    Matcher.new(domain_or_domains, attempt_ip: attempt_ip).match?(allow_with_approval: true)
  end
end
