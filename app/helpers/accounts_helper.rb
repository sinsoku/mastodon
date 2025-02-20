# frozen_string_literal: true

module AccountsHelper
  # @rbs (Account, **nil | bool) -> (String | void | ActiveSupport::SafeBuffer)
  def display_name(account, **options)
    str = account.display_name.presence || account.username

    if options[:custom_emojify]
      prerender_custom_emojis(h(str), account.emojis)
    else
      str
    end
  end

  # @rbs (Account) -> (String | void)
  def acct(account)
    if account.local?
      "@#{account.acct}@#{site_hostname}"
    else
      "@#{account.pretty_acct}"
    end
  end

  # @rbs (Integer) -> (void | ActiveSupport::SafeBuffer)
  def account_formatted_stat(value)
    number_to_human(value, precision: 3, strip_insignificant_zeros: true)
  end

  # @rbs (Account) -> String
  def account_description(account)
    prepend_str = [
      [
        account_formatted_stat(account.statuses_count),
        I18n.t('accounts.posts', count: account.statuses_count),
      ].join(' '),

      [
        account_formatted_stat(account.following_count),
        I18n.t('accounts.following', count: account.following_count),
      ].join(' '),

      [
        account_formatted_stat(account.followers_count),
        I18n.t('accounts.followers', count: account.followers_count),
      ].join(' '),
    ].join(', ')

    [prepend_str, account.note].join(' · ')
  end
end
