# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom
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

  index download_links: lambda {
                          params[:action] == 'show' ? [:pdf] : %i[csv xls json]
                        }, row_class: lambda { |elem|
                                        'anonyme' if elem.anonyme?
                                      } do
    column(:nom) { |e| nom_pour_evaluation(e) }
    column :campagne
    column :created_at
    actions
  end

  xls do
    whitelist
    column('Structure') { |evaluation| evaluation.campagne.compte.structure.nom }
    column(:campagne) { |evaluation| evaluation.campagne.libelle }
    column('Date') { |evaluation| l(evaluation.created_at, format: :court) }
    column :nom
    column('Niveau global') do |evaluation|
      restitution = restitutions_globales[evaluation.id]
      niveau_global(restitution)
    end
    column('Niveau cefr') do |evaluation|
      restitution = restitutions_globales[evaluation.id]
      niveau_cefr(restitution, :litteratie)
    end
    column('Niveau cnef') do |evaluation|
      restitution = restitutions_globales[evaluation.id]
      niveau_cefr(restitution, :numeratie)
    end
    column('ANLCI Littératie') do |evaluation|
      restitution = restitutions_globales[evaluation.id]
      niveau_anlci(restitution, :litteratie)
    end
    column('ANLCI Numératie') do |evaluation|
      restitution = restitutions_globales[evaluation.id]
      niveau_anlci(restitution, :numeratie)
    end
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
    helper_method :restitution_globale, :parties, :auto_positionnement, :statistiques,
                  :mes_avec_redaction_de_notes, :campagnes_accessibles, :niveau_global,
                  :niveau_cefr, :niveau_anlci, :restitutions_globales

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

    def mes_avec_redaction_de_notes
      @mes_avec_redaction_de_notes ||= restitution_globale.restitutions.select do |restitution|
        %w[questions livraison].include?(restitution.situation.nom_technique) &&
          !restitution.questions_redaction.empty?
      end
    end

    def auto_positionnement
      restitution_globale.restitutions.select do |restitution|
        restitution.situation.nom_technique == Restitution::Bienvenue::NOM_TECHNIQUE
      end.last
    end

    def parties
      Partie.where(evaluation_id: resource).includes(:situation).order(:created_at)
    end

    def campagnes_accessibles
      @campagnes_accessibles ||= Campagne.accessible_by(current_ability)
    end

    def restitutions_globales
      @restitutions_globales ||= fabrique_restitutions_globales
    end

    def fabrique_restitutions_globales
      restitutions = {}
      @evaluations.each do |e|
        restitution = FabriqueRestitution.restitution_globale(e)
        restitutions[e.id] = restitution
      end
      restitutions
    end

    def niveau_global(restitution)
      return if restitution.blank?

      t("admin.restitutions.cefr.niveau_global.#{restitution.synthese}")
    end

    def niveau_cefr(restitution, competence)
      return if restitution.blank?

      interpretations = restitution.interpretations_niveau1_cefr
      traduction_niveau(interpretations, competence, 'cefr')
    end

    def niveau_anlci(restitution, competence)
      return if restitution.blank?

      interpretations = restitution.interpretations_niveau1_anlci
      traduction_niveau(interpretations, competence, 'anlci')
    end

    def traduction_niveau(interpretations, competence, referenciel)
      competence_et_niveau = interpretations.find { |element| element.keys.first == competence }
      niveau = competence_et_niveau[competence]
      scope = "admin.restitutions.#{referenciel}.#{competence}"
      t("#{niveau}.profil", scope: scope) unless niveau.blank?
    end
  end
end
