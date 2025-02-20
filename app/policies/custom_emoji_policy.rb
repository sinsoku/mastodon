# frozen_string_literal: true

class CustomEmojiPolicy < ApplicationPolicy
  # @rbs () -> bool
  def index?
    role.can?(:manage_custom_emojis)
  end

  # @rbs () -> bool
  def create?
    role.can?(:manage_custom_emojis)
  end

  # @rbs () -> bool
  def update?
    role.can?(:manage_custom_emojis)
  end

  # @rbs () -> bool
  def copy?
    role.can?(:manage_custom_emojis)
  end

  # @rbs () -> bool
  def enable?
    role.can?(:manage_custom_emojis)
  end

  # @rbs () -> bool
  def disable?
    role.can?(:manage_custom_emojis)
  end

  # @rbs () -> bool
  def destroy?
    role.can?(:manage_custom_emojis)
  end
end
