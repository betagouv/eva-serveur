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
      campagnes_link,
      evaluations_link,
      accompagnement_group,
      beneficiaires_link,
      comptes_link,
      parcours_group,
      structures_group,
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

  def campagnes_link
    return unless current_compte_structure_present?
    return if utilisateur_entreprise?
    return unless can?(:read, Campagne)

    { label: "Campagnes", url: helpers.admin_campagnes_path,
      current: current_page?(helpers.admin_campagnes_path) || controller_matches?("admin/campagnes") }
  end

  def beneficiaires_link
    return unless current_compte_structure_present?
    return if utilisateur_entreprise?
    return unless can?(:read, Beneficiaire)

    { label: "Bénéficiaires", url: helpers.admin_beneficiaires_path,
      current: current_page?(helpers.admin_beneficiaires_path) || controller_matches?("admin/beneficiaires") }
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

  def accompagnement_group
    links = [
      source_aides_link,
      annonce_generales_link
    ].compact
    return if links.empty?

    group_link("Accompagnement", "accompagnement", links)
  end

  def parcours_group
    links = [
      parcours_types_link,
      questionnaires_link,
      questions_qcm_link,
      questions_clic_dans_image_link,
      questions_clic_dans_texte_link,
      questions_glisser_deposer_link,
      questions_saisie_link,
      questions_sous_consigne_link,
      situations_link
    ].compact
    return if links.empty?

    group_link("Parcours", "parcours", links)
  end

  def structures_group
    links = [
      structures_locales_link,
      structures_administratives_link,
      opcos_link
    ].compact
    return if links.empty?

    group_link("Structures", "structures", links)
  end

  def source_aides_link
    return unless can?(:read, SourceAide)

    { label: "Sources d'aide", url: helpers.admin_source_aides_path,
      current: current_page?(helpers.admin_source_aides_path) || controller_matches?("admin/source_aides") }
  end

  def annonce_generales_link
    return unless can?(:read, AnnonceGenerale)

    { label: "Annonces générales", url: helpers.admin_annonce_generales_path,
      current: current_page?(helpers.admin_annonce_generales_path) || controller_matches?("admin/annonce_generales") }
  end

  def parcours_types_link
    return unless can?(:manage, Compte)

    { label: "Parcours", url: helpers.admin_parcours_type_index_path,
      current: current_page?(helpers.admin_parcours_type_index_path) || controller_matches?("admin/parcours_types") }
  end

  def questionnaires_link
    return unless can?(:manage, Compte)

    { label: "Questionnaires", url: helpers.admin_questionnaires_path,
      current: current_page?(helpers.admin_questionnaires_path) || controller_matches?("admin/questionnaires") }
  end

  def situations_link
    return unless can?(:manage, Compte)

    { label: "Situations", url: helpers.admin_situations_path,
      current: current_page?(helpers.admin_situations_path) || controller_matches?("admin/situations") }
  end

  def questions_qcm_link
    return unless can?(:manage, Compte)

    { label: "Questions QCM", url: helpers.admin_question_qcms_path,
      current: current_page?(helpers.admin_question_qcms_path) || controller_matches?("admin/question_qcms") }
  end

  def questions_clic_dans_image_link
    return unless can?(:manage, Compte)

    {
      label: "Questions clic dans image",
      url: helpers.admin_questions_clic_dans_image_path,
      current: current_page?(helpers.admin_questions_clic_dans_image_path) ||
        controller_matches?("admin/questions_clic_dans_image")
    }
  end

  def questions_clic_dans_texte_link
    return unless can?(:manage, Compte)

    {
      label: "Questions clic dans texte",
      url: helpers.admin_questions_clic_dans_texte_path,
      current: current_page?(helpers.admin_questions_clic_dans_texte_path) ||
        controller_matches?("admin/questions_clic_dans_texte")
    }
  end

  def questions_glisser_deposer_link
    return unless can?(:manage, Compte)

    {
      label: "Questions glisser déposer",
      url: helpers.admin_questions_glisser_deposer_path,
      current: current_page?(helpers.admin_questions_glisser_deposer_path) ||
        controller_matches?("admin/questions_glisser_deposer")
    }
  end

  def questions_saisie_link
    return unless can?(:manage, Compte)

    {
      label: "Questions saisie",
      url: helpers.admin_questions_saisies_path,
      current: current_page?(helpers.admin_questions_saisies_path) ||
        controller_matches?("admin/questions_saisies")
    }
  end

  def questions_sous_consigne_link
    return unless superadmin?

    {
      label: "Questions sous consigne",
      url: helpers.admin_question_sous_consignes_path,
      current: current_page?(helpers.admin_question_sous_consignes_path) ||
        controller_matches?("admin/question_sous_consignes")
    }
  end

  def structures_locales_link
    return unless anlci_or_administratif?

    { label: "Structures locales", url: helpers.admin_structures_locales_path,
      current: current_page?(helpers.admin_structures_locales_path) || controller_matches?("admin/structures_locales") }
  end

  def structures_administratives_link
    return unless anlci_or_administratif?

    {
      label: "Structures administratives",
      url: helpers.admin_structures_administratives_path,
      current: current_page?(helpers.admin_structures_administratives_path) ||
        controller_matches?("admin/structures_administratives")
    }
  end

  def opcos_link
    return unless superadmin?

    { label: "Opcos", url: helpers.admin_opcos_path,
      current: current_page?(helpers.admin_opcos_path) || controller_matches?("admin/opcos") }
  end

  def group_link(label, key, links)
    {
      label: label,
      key: key,
      links: links,
      current: links.any? { |link| link[:current] }
    }
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

  def current_compte_structure_present?
    @current_compte&.structure_id.present?
  end

  def utilisateur_entreprise?
    @current_compte&.utilisateur_entreprise?
  end

  def anlci_or_administratif?
    @current_compte&.anlci? || @current_compte&.administratif?
  end

  def superadmin?
    @current_compte&.superadmin?
  end

  def can?(action, subject, *extra_args)
    return false unless @current_compte.present?

    Ability.new(@current_compte).can?(action, subject, *extra_args)
  end

  def current_page?(path)
    helpers.current_page?(path)
  end

  def controller_matches?(*controllers)
    controllers.include?(helpers.params[:controller])
  end
end
