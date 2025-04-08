# frozen_string_literal: true

class LanguagePresenter < ActiveModelSerializers::Model
  attributes :code, :name, :native_name

  # @rbs (Symbol) -> void
  def initialize(code)
    super()

    @code = code
    @item = LanguagesHelper::SUPPORTED_LOCALES[code]
  end

  # @rbs () -> String
  def name
    @item[0]
  end

  def native_name
    @item[1]
  end
end
