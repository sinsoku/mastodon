# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  THEME_COLORS = {
    dark: '#181820',
    light: '#ffffff',
  }.freeze

  # @rbs () -> void
  def initialize
    @conf = YAML.load_file(Rails.root.join('config', 'themes.yml'))
  end

  # @rbs () -> Array[untyped]
  def names
    ['system'] + @conf.keys
  end
end
