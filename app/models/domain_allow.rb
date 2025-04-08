# frozen_string_literal: true

# == Schema Information
#
# Table name: domain_allows
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DomainAllow < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include DomainMaterializable

  validates :domain, presence: true, uniqueness: true, domain: true

  # @rbs () -> String
  def to_log_human_identifier
    domain
  end

  class << self
    # @rbs (String) -> bool
    def allowed?(domain)
      !rule_for(domain).nil?
    end

    # @rbs () -> DomainAllow::ActiveRecord_Relation
    def allowed_domains
      select(:domain)
    end

    # @rbs (String) -> DomainAllow?
    def rule_for(domain)
      return if domain.blank?

      uri = Addressable::URI.new.tap { |u| u.host = domain.delete('/') }

      find_by(domain: uri.normalized_host)
    end
  end
end
