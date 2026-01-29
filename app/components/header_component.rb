# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  delegate :current_compte, to: :helpers

  def initialize(logo:, logo_alt:, titre: nil, tagline: nil, logo_url: nil)
    @logo = logo
    @logo_alt = logo_alt
    @logo_url = logo_url
    @titre = titre
    @tagline = tagline
  end

  def affiche_actions_connexion?
    current_compte.present?
  end

  def affiche_titre?
    @titre.present?
  end

  def deconnexion_path
    if helpers.respond_to?(:pro_connect_logout_path)
      helpers.pro_connect_logout_path
    else
      helpers.destroy_compte_session_path
    end
  end
end
