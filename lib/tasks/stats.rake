# frozen_string_literal: true

namespace :stats do
  desc 'Extrait les données pour la bascule vers un algorithme figé'
  task niveau_1_et2: :environment do
    evaluations = Evaluation.joins(campagne: :compte).where(comptes: { role: :organisation })
    puts "Nombre d'évaluation : #{evaluations.count}"
    entete_colonnes = [
      'id eva', 'campagne', 'date creation de la partie', 'litteratie_z', 'numeratie_z',
      'synthese illettrisme', 'score_ccf', 'score_syntaxe_orthographe', 'score_memorisation',
      'score_numeratie'
    ].join(';')
    puts entete_colonnes
    evaluations.each do |e|
      rg = FabriqueRestitution.restitution_globale(e)
      scores = rg.scores_niveau1_standardises.calcule
      scores_metacompetence = rg.scores_niveau2_standardises.calcule
      colonnes = [
        e.id,
        e.campagne&.code, e.created_at,
        scores.values.join(';'),
        rg.interpreteur_niveau1.synthese,
        %i[score_ccf score_syntaxe_orthographe score_memorisation score_numeratie].map do |score|
          scores_metacompetence[score]
        end.join(';')
      ]
      puts colonnes.join(';')
    end
  end
end
