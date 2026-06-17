# frozen_string_literal: true

module ResetPassword
  class PageContext
    include Rails.application.routes.url_helpers

    def initialize(action_name:, token_invalide:, reset_password_token:, resource_class: Compte)
      @action_name = action_name
      @token_invalide = ActiveModel::Type::Boolean.new.cast(token_invalide)
      @reset_password_token = reset_password_token
      @resource_class = resource_class
    end

    def state
      return :invalid_link if @token_invalide
      return :change_password if %w[edit update].include?(@action_name)

      :request_email
    end

    def request_email?
      state == :request_email
    end

    def change_password?
      state == :change_password
    end

    def invalid_link?
      state == :invalid_link
    end

    def compte
      @compte ||= find_compte_by_token
    end

    def token_valide?
      change_password? && compte.present? && compte.reset_password_period_valid?
    end

    def redirect_path_si_token_invalide
      return if token_valide? || !change_password?

      new_compte_password_path(token_invalide: true)
    end

    def hint_mot_de_passe
      cle = compte&.anlci? ? :regles_mot_de_passe_anlci : :regles_mot_de_passe
      I18n.t(cle, scope: "creation_compte", longueur_mot_de_passe: Devise.password_length.first)
    end

    def i18n_scope
      invalid_link? ? "invalid_link" : "request_email"
    end

    def page_title
      case state
      when :invalid_link
        I18n.t("active_admin.devise.reset_password.invalid_link.title")
      when :change_password
        I18n.t("active_admin.devise.change_password.title")
      else
        I18n.t("active_admin.devise.reset_password.request_email.title")
      end
    end

    def email_submit_button_id
      invalid_link? ? "reset-password-invalid-submit" : "reset-password-request-submit"
    end

    def wrapper_modifier_class
      case state
      when :invalid_link then "page-reset-password--invalid-link"
      when :request_email then "page-reset-password--request-email"
      else "page-reset-password--change-password"
      end
    end

    def t_email(key)
      I18n.t(key, scope: "active_admin.devise.reset_password.#{i18n_scope}")
    end

    private

    def find_compte_by_token
      return if @reset_password_token.blank?

      @resource_class.find_by(
        reset_password_token: Devise.token_generator.digest(
          @resource_class,
          :reset_password_token,
          @reset_password_token
        )
      )
    end
  end
end
