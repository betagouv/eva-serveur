# frozen_string_literal: true

ActiveAdmin.register Evaluation, as: 'Stats' do
  belongs_to :campagne
  config.batch_actions = false
  config.sort_order = 'created_at_desc'

  filter :nom
  filter :created_at

  column_stats = proc do |situation, metrique|
    proc do
      column "#{situation}_#{metrique}".to_sym do |evaluation|
        restitution(evaluation, situation)&.send(metrique)
      end
    end
  end

  column_question = proc do |question|
    proc do
      column "questions_#{question.libelle}".to_sym do |evaluation|
        restitution(evaluation, 'questions')&.choix_repondu(question)&.type_choix
      end
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
    instance_eval(&column_stats.call('securite', :temps_entrainement))
    instance_eval(&column_stats.call('securite', :temps_total))
    instance_eval(&column_stats.call('securite', :nombre_dangers_bien_identifies))
    instance_eval(&column_stats.call('securite', :nombre_danger_mal_identifies))
    instance_eval(&column_stats.call('securite', :nombre_dangers_bien_identifies_avant_aide_1))
    instance_eval(&column_stats.call('securite', :nombre_bien_qualifies))
    instance_eval(&column_stats.call('securite', :nombre_retours_deja_qualifies))
    instance_eval(&column_stats.call('securite', :delai_moyen_ouvertures_zones_dangers))
    instance_eval(&column_stats.call('securite', :attention_visuo_spatiale))
    instance_eval(&column_stats.call('securite', :nombre_reouverture_zone_sans_danger))
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
    instance_eval(&column_stats.call('inventaire', :efficience))
    instance_eval(&column_stats.call('inventaire', :temps_total))
    instance_eval(&column_stats.call('inventaire', :nombre_ouverture_contenant))
    instance_eval(&column_stats.call('inventaire', :nombre_essais_validation))
    instance_eval(&column_stats.call('controle', :efficience))
    instance_eval(&column_stats.call('controle', :nombre_bien_placees))
    instance_eval(&column_stats.call('controle', :nombre_mal_placees))
    instance_eval(&column_stats.call('controle', :nombre_non_triees))
    instance_eval(&column_stats.call('tri', :efficience))
    instance_eval(&column_stats.call('tri', :temps_total))
    instance_eval(&column_stats.call('tri', :nombre_bien_placees))
    instance_eval(&column_stats.call('tri', :nombre_mal_placees))
    instance_eval(&column_stats.call('questions', :temps_total))
    instance_eval(&column_stats_securite)
    collection.first.campagne.questionnaire&.questions&.each do |question|
      next unless question.is_a?(QuestionQcm)

      instance_eval(&column_question.call(question))
    end
  end

  csv do
    instance_eval(&columns_stats)
  end

  index do
    instance_eval(&columns_stats)
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
