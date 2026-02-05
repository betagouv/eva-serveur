# frozen_string_literal: true

class NavigationComponent < ViewComponent::Base
  def initialize(links: nil, current_compte: nil)
    @links = links
    @current_compte = current_compte
  end

  def links
    return @links if @links
    return [] unless @current_compte.present?

    default_links
  end

  def aria_current(link)
    "page" if link[:current]
  end

  private

  def default_links
    [
      dashboard_link,
      actualites_link,
      evaluations_link,
      comptes_link,
      aide_link
    ]
  end

  def dashboard_link
    { label: "Tableau de bord", url: helpers.admin_root_path, current: dashboard_current? }
  end

  def actualites_link
    { label: "Actualités", url: helpers.admin_actualites_path,
      current: current_page?(helpers.admin_actualites_path) }
  end

  def evaluations_link
    { label: "Évaluations", url: helpers.admin_evaluations_path,
      current: current_page?(helpers.admin_evaluations_path) }
  end

  def comptes_link
    { label: "Comptes", url: helpers.admin_comptes_path,
      current: current_page?(helpers.admin_comptes_path) }
  end

  def aide_link
    { label: "Aide", url: helpers.admin_aide_path,
      current: current_page?(helpers.admin_aide_path) }
  end

  def dashboard_current?
    current_page?(helpers.admin_root_path) || helpers.params[:controller] == "admin/dashboard"
  end

  def current_page?(path)
    helpers.current_page?(path)
  end
end
