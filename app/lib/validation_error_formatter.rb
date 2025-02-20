# frozen_string_literal: true

class ValidationErrorFormatter
  # @rbs (ActiveRecord::RecordInvalid, ?Hash[untyped, untyped]) -> void
  def initialize(error, aliases = {})
    @error   = error
    @aliases = aliases
  end

  # @rbs () -> void
  def as_json
    { error: @error.to_s, details: details }
  end

  private

  # @rbs () -> void
  def details
    h = {}

    errors.details.each_pair do |attribute_name, attribute_errors|
      messages = errors.messages[attribute_name]

      h[@aliases[attribute_name] || attribute_name] = attribute_errors.map.with_index do |error, index|
        { error: "ERR_#{error[:error].to_s.upcase}", description: messages[index] }
      end
    end

    h
  end

  # @rbs () -> ActiveModel::Errors
  def errors
    @errors ||= @error.record.errors
  end
end
