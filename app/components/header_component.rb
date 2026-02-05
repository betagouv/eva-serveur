# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  def initialize(logo:, logo_alt:, titre: nil, tagline: nil, logo_url: nil, current_compte: nil,
actions: nil, nav_links: nil, logged_in: nil, show_navigation: nil)
    @logo = logo
    @logo_alt = logo_alt
    @logo_url = logo_url
    @titre = titre
    @tagline = tagline
    @current_compte = current_compte
    @actions = actions
    @nav_links = nav_links
    @logged_in = logged_in
    @show_navigation = show_navigation
  end

  def affiche_actions_connexion?
    @current_compte.present? && actions.any?
  end

  def affiche_titre?
    @titre.present?
  end

  def affiche_navigation?
    return false if @show_navigation == false
    return true if @show_navigation == true

    @nav_links.present? || current_compte_present?
  end

  def logged_in?
    return @logged_in if [ true, false ].include?(@logged_in)

    @current_compte.present?
  end

  def actions
    return @actions if @actions

    items = []
    if current_compte_present?
      items << {
        url: helpers.admin_compte_path(@current_compte),
        label: @current_compte.nom_complet,
        icon_class: "fr-icon-account-circle-line",
        button_class: "fr-btn fr-btn--tertiary"
      }
    end
    if current_compte_present? && current_structure.present?
      items << {
        url: helpers.polymorphic_path([ :admin, current_structure ]),
        label: "Ma structure",
        icon_class: "fr-icon-building-line",
        button_class: "fr-btn fr-btn--tertiary"
      }
    end
    items << {
      url: helpers.pro_connect_logout_path,
      label: "Déconnexion",
      icon_class: "fr-icon-logout-box-r-line",
      button_class: "fr-btn fr-btn--tertiary"
    }
    items
  end

  private

  def current_compte_present?
    @current_compte.present?
  end

  def current_structure
    @current_compte&.structure
  end
end
