# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom, :beneficiaire_id, :statut, :responsable_suivi_id
  menu priority: 4

  includes :responsable_suivi, campagne: [:parcours_type]

  config.sort_order = 'created_at_desc'

  filter :nom
  filter :campagne_id,
         as: :search_select_filter,
         url: proc { admin_campagnes_path },
         fields: %i[libelle code],
         display_name: 'display_name',
         minimum_input_length: 2,
         order_by: 'libelle_asc'
  filter :created_at
  filter :responsable_suivi_id,
         as: :search_select_filter,
         url: proc { admin_comptes_path },
         fields: %i[email nom prenom],
         display_name: 'display_name',
         minimum_input_length: 2,
         order_by: 'email_asc'
  filter :statut,
         as: :select,
         collection: Evaluation.statuts.map { |v, id|
           [Evaluation.human_enum_name(:statut, v), id]
         },
         if: proc { current_compte.superadmin? }

  scope proc { I18n.t('activerecord.scopes.evaluation.all') }, :all, default: true
  scope proc {
          render(PastilleComponent.new(
                   couleur: 'alerte',
                   etiquette: I18n.t('components.pastille.illettrisme_potentiel')
                 ))
        }, :illettrisme_potentiel

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: 'show'
  end

  index download_links: lambda {
                          params[:action] == 'show' ? %i[pdf] : %i[xls]
                        }, row_class: lambda { |elem|
                                        'anonyme' if elem.anonyme?
                                      } do
    render 'index', context: self
  end

  form partial: 'form'

  sidebar :statistiques, only: :index, if: proc { can?(:manage, Compte) } do
    ul do
      collection_complete = collection.except(:limit, :offset, :order)
      evaluations_par_synthese = collection_complete.select(:synthese_competences_de_base)
                                                    .group(:synthese_competences_de_base)
                                                    .count
      evaluations_par_synthese.delete(nil)

      div do
        pie_chart evaluations_par_synthese
      end
    end
  end

  sidebar :responsable_de_suivi, only: :show, if: proc { resource.responsable_suivi.present? } do
    render(Tag.new(resource.responsable_suivi.display_name,
                   supprimable: can?(:supprimer_responsable_suivi, Evaluation),
                   url: supprimer_responsable_suivi_admin_evaluation_path(resource)))
  end

  sidebar :responsable_de_suivi, only: :show, if: proc {
                                                    resource.responsable_suivi.blank? and
                                                      can?(:ajouter_responsable_suivi, Evaluation)
                                                  } do
    render 'recherche_responsable_suivi'
  end

  sidebar :menu, class: 'menu-sidebar', only: :show

  xls(i18n_scope: %i[active_admin xls evaluation]) do
    whitelist
    column('structure') { |evaluation| evaluation.campagne&.compte&.structure&.nom }
    column(:campagne) { |evaluation| evaluation.campagne&.libelle }
    column(:created_at) { |evaluation| I18n.l(evaluation.created_at, format: :sans_heure) }
    column :nom
    column(:completude) do |evaluation|
      I18n.t(evaluation.completude, scope: 'activerecord.attributes.evaluation')
    end
    column(:synthese_competences_de_base) do |evaluation|
      traduction_niveau(evaluation, :synthese_competences_de_base)
    end
    column(:niveau_cefr) { |evaluation| traduction_niveau(evaluation, :niveau_cefr) }
    column(:niveau_cnef) { |evaluation| traduction_niveau(evaluation, :niveau_cnef) }
    column(:niveau_anlci_litteratie) do |evaluation|
      traduction_niveau(evaluation, :niveau_anlci_litteratie)
    end
    column(:niveau_anlci_numeratie) do |evaluation|
      traduction_niveau(evaluation, :niveau_anlci_numeratie)
    end
    column(:positionnement_niveau_litteratie) do |evaluation|
      traduction_niveau(evaluation, :positionnement_niveau_litteratie)
    end
  end

  member_action :mise_en_action, method: :put do
    resource.enregistre_mise_en_action(params[:mise_en_action_effectuee])
  end

  member_action :supprimer_responsable_suivi, method: :patch do
    resource.update(responsable_suivi: nil)
    redirect_to request.referer
  end

  member_action :ajouter_responsable_suivi, method: :post do
    responsable = Compte.where(id: params['responsable_suivi_id']).first
    resource.update(responsable_suivi: responsable) if responsable.present?
    redirect_to admin_evaluation_path(resource)
  end

  member_action :renseigner_qualification, method: :patch do
    mise_en_action = resource.mise_en_action
    mise_en_action.update(mise_en_action.questionnaire => params[:reponse])
  end

  controller do
    helper_method :restitution_globale, :parties, :prise_en_main?, :auto_positionnement,
                  :restitution_cafe_de_la_place, :statistiques, :mes_avec_redaction_de_notes,
                  :campagnes_accessibles, :beneficiaires_possibles, :traduction_niveau,
                  :campagne_avec_competences_transversales?, :campagne_avec_positionnement?,
                  :responsables_suivi_possibles

    def show
      show! do |format|
        format.html
        format.pdf { render pdf: resource.nom }
      end
    end

    def destroy
      destroy!(location: admin_campagne_path(resource.campagne))
    end

    before_action only: :show do
      flash.now[:evaluation_anonyme] = t('.evaluation_anonyme') if resource.anonyme?
    end

    private

    def statistiques
      @statistiques ||= StatistiquesEvaluation.new(resource)
    end

    def restitution_globale
      @restitution_globale ||=
        FabriqueRestitution.restitution_globale(resource, params[:parties_selectionnees])
    end

    def traduction_niveau(evaluation, interpretation)
      scope = 'activerecord.attributes.evaluation.interpretations'
      niveau = evaluation.send(interpretation)
      t("#{interpretation}.#{niveau}", scope: scope) if niveau.present?
    end

    def mes_avec_redaction_de_notes
      @mes_avec_redaction_de_notes ||= restitution_globale.restitutions.select do |restitution|
        %w[questions livraison].include?(restitution.situation.nom_technique) &&
          !restitution.questions_redaction.empty?
      end
    end

    def campagne_avec_competences_transversales?
      @evaluation.campagne.avec_competences_transversales?
    end

    def campagne_avec_positionnement?
      @evaluation.campagne.avec_positionnement?
    end

    def prise_en_main?
      selectionne_derniere_restitution(Situation::PLAN_DE_LA_VILLE)&.termine?
    end

    def auto_positionnement
      selectionne_derniere_restitution(Situation::BIENVENUE)
    end

    def restitution_cafe_de_la_place
      selectionne_derniere_restitution(Situation::CAFE_DE_LA_PLACE)
    end

    def selectionne_derniere_restitution(nom)
      restitution_globale.restitutions.reverse.find do |restitution|
        restitution.situation.nom_technique == nom
      end
    end

    def parties
      Partie.where(evaluation_id: resource).includes(:situation).order(:created_at)
    end

    def campagnes_accessibles
      @campagnes_accessibles ||= Campagne.accessible_by(current_ability)
    end

    def responsables_suivi_possibles
      @responsables_suivi_possibles ||= resource.responsables_suivi
    end

    def beneficiaires_possibles
      @beneficiaires_possibles ||= resource.beneficiaires_possibles
    end
  end
end
