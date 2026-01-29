# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  def initialize(logo:, logo_alt:, titre: nil, tagline: nil, logo_url: nil, current_compte: nil,
actions: [])
    @logo = logo
    @logo_alt = logo_alt
    @logo_url = logo_url
    @titre = titre
    @tagline = tagline
    @current_compte = current_compte
    @actions = actions
  end

  def affiche_actions_connexion?
    @current_compte.present? && @actions.any?
  end

  def affiche_titre?
    @titre.present?
  end
end
