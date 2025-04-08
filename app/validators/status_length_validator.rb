# frozen_string_literal: true

class StatusLengthValidator < ActiveModel::Validator
  MAX_CHARS = 500
  URL_PLACEHOLDER_CHARS = 23
  URL_PLACEHOLDER = 'x' * 23

  # @rbs (Status | RSpec::Mocks::InstanceVerifyingDouble) -> nil
  def validate(status)
    return unless status.local? && !status.reblog?

    status.errors.add(:text, I18n.t('statuses.over_character_limit', max: MAX_CHARS)) if too_long?(status)
  end

  private

  # @rbs (Status | RSpec::Mocks::InstanceVerifyingDouble) -> bool
  def too_long?(status)
    countable_length(combined_text(status)) > MAX_CHARS
  end

  # @rbs (String) -> Integer
  def countable_length(str)
    str.mb_chars.grapheme_length
  end

  # @rbs (Status | RSpec::Mocks::InstanceVerifyingDouble) -> String
  def combined_text(status)
    [status.spoiler_text, countable_text(status.text)].join
  end

  # @rbs (String) -> String
  def countable_text(str)
    return '' if str.blank?

    # To ensure that we only give length concessions to entities that
    # will be correctly parsed during formatting, we go through full
    # entity extraction

    entities = Extractor.remove_overlapping_entities(Extractor.extract_urls_with_indices(str, extract_url_without_protocol: false) + Extractor.extract_mentions_or_lists_with_indices(str))

    rewrite_entities(str, entities) do |entity|
      if entity[:url]
        URL_PLACEHOLDER
      elsif entity[:screen_name]
        "@#{entity[:screen_name].split('@').first}"
      end
    end
  end

  # @rbs (String, Array[untyped]) -> String
  def rewrite_entities(str, entities)
    entities.sort_by! { |entity| entity[:indices].first }
    result = +''

    last_index = entities.reduce(0) do |index, entity|
      result << str[index...entity[:indices].first]
      result << yield(entity)
      entity[:indices].last
    end

    result << str[last_index..]
    result
  end
end
