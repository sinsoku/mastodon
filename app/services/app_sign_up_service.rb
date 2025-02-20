# frozen_string_literal: true

class AppSignUpService < BaseService
  include RegistrationHelper

  # @rbs (Doorkeeper::Application, String | IPAddr, ActionController::Parameters | Hash[untyped, untyped]) -> (Doorkeeper::AccessToken | void)?
  def call(app, remote_ip, params)
    @app       = app
    @remote_ip = remote_ip
    @params    = params

    raise Mastodon::NotPermittedError unless allowed_registration?(remote_ip, invite)

    ApplicationRecord.transaction do
      create_user!
      create_access_token!
    end

    @access_token
  end

  private

  # @rbs () -> void
  def create_user!
    @user = User.create!(
      user_params.merge(created_by_application: @app, sign_up_ip: @remote_ip, password_confirmation: user_params[:password], account_attributes: account_params, invite_request_attributes: invite_request_params)
    )
  end

  # @rbs () -> void
  def create_access_token!
    @access_token = Doorkeeper::AccessToken.create!(
      application: @app,
      resource_owner_id: @user.id,
      scopes: @app.scopes,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
    )
  end

  # @rbs () -> void
  def invite
    Invite.find_by(code: @params[:invite_code]) if @params[:invite_code].present?
  end

  # @rbs () -> (ActionController::Parameters | Hash[untyped, untyped])
  def user_params
    @params.slice(:email, :password, :agreement, :locale, :time_zone, :invite_code)
  end

  # @rbs () -> void
  def account_params
    @params.slice(:username)
  end

  # @rbs () -> void
  def invite_request_params
    { text: @params[:reason] }
  end
end
