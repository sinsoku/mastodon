# frozen_string_literal: true

module Settings
  module TwoFactorAuthentication
    class OtpAuthenticationController < BaseController
      include ChallengableConcern

      skip_before_action :require_functional!

      before_action :verify_otp_not_enabled, only: [:show]
      before_action :require_challenge!, only: [:create]

      # @rbs () -> Form::TwoFactorConfirmation
      def show
        @confirmation = Form::TwoFactorConfirmation.new
      end

      # @rbs () -> String
      def create
        session[:new_otp_secret] = User.generate_otp_secret

        redirect_to new_settings_two_factor_authentication_confirmation_path
      end

      private

      # @rbs () -> String?
      def verify_otp_not_enabled
        redirect_to settings_two_factor_authentication_methods_path if current_user.otp_enabled?
      end
    end
  end
end
