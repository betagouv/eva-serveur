# frozen_string_literal: true

namespace :stats do
  desc 'Extrait les données pour la bascule vers un algorithme figé'
  task niveau_1_et2: :environment do
    evaluations = recupere_evaluations
    puts "Nombre d'évaluation : #{evaluations.count}"
    puts entete_colonnes
    evaluations.each do |e|
      rg = FabriqueRestitution.restitution_globale(e)
      scores = rg.scores_niveau1_standardises.calcule
      scores_metacompetence = rg.scores_niveau2_standardises.calcule
      campagne = e.campagne
      structure = campagne&.compte&.structure
      colonnes = [
        e.id,
        campagne&.code, e.created_at,
        scores.values.join(';'),
        rg.interpreteur_niveau1.synthese,
        %i[score_ccf score_syntaxe_orthographe score_memorisation score_numeratie].map do |score|
          scores_metacompetence[score]
        end.join(';'),
        structure&.type_structure
      ]
      puts colonnes.join(';')
    end
  end

  def entete_colonnes
    [
      'id eva', 'campagne', 'date creation de la partie', 'litteratie_z', 'numeratie_z',
      'synthese illettrisme', 'score_ccf', 'score_syntaxe_orthographe', 'score_memorisation',
      'score_numeratie', 'type de structure'
    ].join(';')
  end

  def recupere_evaluations
    Evaluation.includes(
      campagne: [:situations_configurations, { compte: :structure }]
    ).where(comptes: { role: :organisation })
  end
end
