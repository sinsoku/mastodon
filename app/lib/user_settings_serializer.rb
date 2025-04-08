# frozen_string_literal: true

class UserSettingsSerializer
  # @rbs (String?) -> UserSettings
  def self.load(value)
    json = begin
      if value.blank?
        {}
      else
        Oj.load(value, symbol_keys: true)
      end
    end

    UserSettings.new(json)
  end

  # @rbs (UserSettings) -> String
  def self.dump(value)
    Oj.dump(value.as_json)
  end
end
