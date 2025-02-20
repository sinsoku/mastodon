# frozen_string_literal: true

class AnnualReport
  include DatabaseHelper

  SOURCES = [
    AnnualReport::Archetype,
    AnnualReport::TypeDistribution,
    AnnualReport::TopStatuses,
    AnnualReport::MostUsedApps,
    AnnualReport::CommonlyInteractedWithAccounts,
    AnnualReport::TimeSeries,
    AnnualReport::TopHashtags,
    AnnualReport::MostRebloggedAccounts,
    AnnualReport::Percentiles,
  ].freeze

  SCHEMA = 1

  # @rbs () -> void
  def self.table_name_prefix
    'annual_report_'
  end

  # @rbs (Account, Integer) -> void
  def initialize(account, year)
    @account = account
    @year = year
  end

  def self.prepare(year)
    SOURCES.each do |klass|
      klass.prepare(year)
    end
  end

  # @rbs () -> void
  def generate
    return if GeneratedAnnualReport.exists?(account: @account, year: @year)

    GeneratedAnnualReport.create(
      account: @account,
      year: @year,
      schema_version: SCHEMA,
      data: data
    )
  end

  private

  # @rbs () -> void
  def data
    with_read_replica do
      SOURCES.each_with_object({}) { |klass, hsh| hsh.merge!(klass.new(@account, @year).generate) }
    end
  end
end
