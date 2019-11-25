# frozen_string_literal: true

ActiveAdmin.register Evaluation, as: 'Campagne Stats' do
  menu false
  config.sort_order = 'created_at_desc'
  includes :campagne

  column_stats = proc do |situation, nom|
    proc do
      column "#{situation}_#{nom}".to_sym do |evaluation|
        restitution(evaluation, situation)&.send(nom)
      end
    end
  end

  column_question = proc do |question|
    proc do
      column "bureau_#{question.libelle}".to_sym do |evaluation|
        restitution(evaluation, 'questions')&.choix_repondu(question)&.type_choix
      end
    end
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

    def csv_filename
      "campagne_stats_#{collection.first.campagne.code}.csv"
    end
  end
end
