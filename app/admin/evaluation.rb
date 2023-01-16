# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom, :beneficiaire_id, :statut, :responsable_suivi_id
  menu priority: 4

  includes campagne: :compte

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
  filter :mise_en_action_effectuee_null,
         as: :boolean,
         label: I18n.t('activerecord.attributes.evaluation.mise_en_action_effectuee_null')
  filter :statut,
         as: :select,
         collection: Evaluation.statuts.map { |v, id|
           [Evaluation.human_enum_name(:statut, v), id]
         },
         if: proc { current_compte.superadmin? }

  scope proc { I18n.t('activerecord.scopes.evaluation.all') }, :all, default: true
  scope proc {
          render partial: 'pastille_illettrisme_potentiel',
                 locals: {
                   etiquette: I18n.t('activerecord.scopes.evaluation.illettrisme_potentiel')
                 }
        }, :illettrisme_potentiel

  index download_links: lambda {
                          params[:action] == 'show' ? [:pdf] : %i[csv xls json]
                        }, row_class: lambda { |elem|
                                        'anonyme' if elem.anonyme?
                                      } do
    column(:nom) { |e| nom_pour_ressource(e) }

    if params[:scope] != 'illettrisme_potentiel'
      column('Illettrisme potentiel') do |evaluation|
        if evaluation.illettrisme_potentiel?
          render partial: 'pastille_illettrisme_potentiel',
                 locals: { avec_tooltip: true }
        end
      end
    end

    column :campagne
    column :created_at
    actions
  end

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

  xls do
    whitelist
    column('Structure') { |evaluation| evaluation.campagne.compte.structure.nom }
    column(:campagne) { |evaluation| evaluation.campagne.libelle }
    column('Date') { |evaluation| I18n.l(evaluation.created_at, format: :court) }
    column :nom
    column('passation complète') do |evaluation|
      I18n.t(evaluation.completude, scope: 'activerecord.attributes.evaluation')
    end
    column('Niveau global') do |evaluation|
      traduction_niveau(evaluation, :synthese_competences_de_base)
    end
    column('Niveau cefr') do |evaluation|
      traduction_niveau(evaluation, :niveau_cefr)
    end
    column('Niveau cnef') do |evaluation|
      traduction_niveau(evaluation, :niveau_cnef)
    end
    column('ANLCI Littératie') do |evaluation|
      traduction_niveau(evaluation, :niveau_anlci_litteratie)
    end
    column('ANLCI Numératie') do |evaluation|
      traduction_niveau(evaluation, :niveau_anlci_numeratie)
    end
  end

  member_action :mise_en_action, method: :put do
    resource.update(mise_en_action_effectuee: params[:mise_en_action_effectuee])
  end

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: 'show'
  end

  sidebar :menu, class: 'menu-sidebar', only: :show

  form partial: 'form'

  controller do
    helper_method :restitution_globale, :parties, :prise_en_main?, :auto_positionnement,
                  :restitution_cafe_de_la_place, :statistiques, :mes_avec_redaction_de_notes,
                  :campagnes_accessibles, :beneficiaires_accessibles, :traduction_niveau,
                  :campagne_avec_competences_transversales?, :campagne_avec_positionnement?,
                  :responsables_suivi_accessibles

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

    def responsables_suivi_accessibles
      @responsables_suivi_accessibles ||= Compte.accessible_by(current_ability)
    end

    def beneficiaires_accessibles
      @beneficiaires_accessibles ||= Beneficiaire.accessible_by(current_ability)
    end
  end
end
