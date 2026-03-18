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
    ].compact
  end

  def dashboard_link
    return unless can_read_dashboard?

    { label: "Tableau de bord", url: helpers.admin_root_path, current: dashboard_current? }
  end

  def actualites_link
    return unless can?(:read, Actualite)

    { label: "Actualités", url: helpers.admin_actualites_path,
      current: current_page?(helpers.admin_actualites_path) }
  end

  def evaluations_link
    return unless can?(:read, Evaluation)

    { label: "Évaluations", url: helpers.admin_evaluations_path,
      current: evaluations_current? }
  end

  def comptes_link
    return unless can?(:read, Compte)

    { label: "Comptes", url: helpers.admin_comptes_path,
      current: current_page?(helpers.admin_comptes_path) }
  end

  def aide_link
    return unless can_read_aide?

    { label: "Aide", url: helpers.admin_aide_path,
      current: current_page?(helpers.admin_aide_path) }
  end

  def dashboard_current?
    current_page?(helpers.admin_root_path) || helpers.params[:controller] == "admin/dashboard"
  end

  def evaluations_current?
    current_page?(helpers.admin_evaluations_path) ||
      (helpers.params[:controller] == "admin/evaluations" && helpers.params[:action] == "show")
  end

  def can_read_dashboard?
    can?(:read, ActiveAdmin::Page, name: "Dashboard", namespace_name: "admin")
  end

  def can_read_aide?
    can?(:read, ActiveAdmin::Page, name: "Aide", namespace_name: "admin") &&
      can?(:read, SourceAide)
  end

  def can?(action, subject, *extra_args)
    return false unless @current_compte.present?

    Ability.new(@current_compte).can?(action, subject, *extra_args)
  end

  def current_page?(path)
    helpers.current_page?(path)
  end
end
