# frozen_string_literal: true

ActiveAdmin.register Evaluation, as: 'Stats' do
  belongs_to :campagne
  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  filter :nom
  filter :created_at

  column_stats = proc do |situation, metrique|
    column "#{situation}_#{metrique}".to_sym do |evaluation|
      restitution(evaluation, situation)&.send(metrique)
    end
  end

  column_question = proc do |question|
    column "questions_#{question.libelle}".to_sym do |evaluation|
      restitution(evaluation, 'questions')&.choix_repondu(question)&.type_choix
    end
  end

  colonnes_stats_securite_par_danger = proc do |metrique|
    situation = 'securite'
    Restitution::Securite::ZONES_DANGER.each do |danger|
      column "#{situation}_#{metrique}_#{danger}".to_sym do |evaluation|
        restitution(evaluation, situation)&.send(metrique)&.fetch(danger, nil)
      end
    end
  end

  column_stats_securite = proc do
    instance_exec('securite', :temps_entrainement, &column_stats)
    instance_exec('securite', :temps_total, &column_stats)
    instance_exec('securite', :nombre_dangers_bien_identifies, &column_stats)
    instance_exec('securite', :nombre_dangers_mal_identifies, &column_stats)
    instance_exec('securite', :nombre_dangers_bien_identifies_avant_aide_1, &column_stats)
    instance_exec('securite', :nombre_bien_qualifies, &column_stats)
    instance_exec('securite', :nombre_retours_deja_qualifies, &column_stats)
    instance_exec('securite', :delai_moyen_ouvertures_zones_dangers, &column_stats)
    instance_exec('securite', :attention_visuo_spatiale, &column_stats)
    instance_exec('securite', :nombre_reouverture_zone_sans_danger, &column_stats)
    instance_exec(:temps_bonnes_qualifications_dangers, &colonnes_stats_securite_par_danger)
    instance_exec(:temps_recherche_zones_dangers, &colonnes_stats_securite_par_danger)
    instance_exec(:temps_total_ouverture_zones_dangers, &colonnes_stats_securite_par_danger)
  end

  columns_stats = proc do
    column :nom
    column :created_at
    column :efficience do |evaluation|
      restitution_globale(evaluation).efficience
    end
    instance_exec('inventaire', :efficience, &column_stats)
    instance_exec('inventaire', :temps_total, &column_stats)
    instance_exec('inventaire', :nombre_ouverture_contenant, &column_stats)
    instance_exec('inventaire', :nombre_essais_validation, &column_stats)
    instance_exec('controle', :efficience, &column_stats)
    instance_exec('controle', :nombre_bien_placees, &column_stats)
    instance_exec('controle', :nombre_mal_placees, &column_stats)
    instance_exec('controle', :nombre_non_triees, &column_stats)
    instance_exec('tri', :efficience, &column_stats)
    instance_exec('tri', :temps_total, &column_stats)
    instance_exec('tri', :nombre_bien_placees, &column_stats)
    instance_exec('tri', :nombre_mal_placees, &column_stats)
    instance_exec('questions', :temps_total, &column_stats)
    instance_exec(&column_stats_securite)
    collection.first.campagne.questionnaire&.questions&.each do |question|
      next unless question.is_a?(QuestionQcm)

      instance_exec(question, &column_question)
    end
  end

  csv do
    instance_exec(&columns_stats)
  end

  index do
    instance_exec(&columns_stats)
  end

  controller do
    helper_method :restitution_globale, :restitution

    def restitution_globale(evaluation)
      @restitution_globale ||= {}
      @restitution_globale[evaluation.id] ||= FabriqueRestitution.restitution_globale(evaluation)
    end

    def restitution(evaluation, nom_situation)
      restitution_globale(evaluation).restitutions.find do |restitution|
        restitution.situation.nom_technique == nom_situation
      end
    end

    def scoped_collection
      Evaluation.where(campagne: params[:campagne_id])
    end

    def csv_filename
      "#{Time.current.to_formatted_s(:number)}-stats-#{@campagne.code}.csv"
    end
  end
end
