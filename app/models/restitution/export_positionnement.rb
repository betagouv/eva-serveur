# frozen_string_literal: true

module Restitution
  class ExportPositionnement < ExportXls
    ENTETES_LITTERATIE = [{ titre: 'Code Question', taille: 20 },
                          { titre: 'Intitulé', taille: 80 },
                          { titre: 'Réponse', taille: 45 },
                          { titre: 'Score', taille: 10 },
                          { titre: 'Score max', taille: 10 },
                          { titre: 'Métacompétence', taille: 20 }].freeze
    ENTETES_NUMERATIE = [{ titre: 'Code cléa', taille: 10 },
                         { titre: 'Item', taille: 20 },
                         { titre: 'Méta compétence', taille: 20 },
                         { titre: 'Interaction', taille: 20 },
                         { titre: 'Intitulé de la question', taille: 80 },
                         { titre: 'Réponses possibles', taille: 20 },
                         { titre: 'Réponses attendue', taille: 20 },
                         { titre: 'Réponse du bénéficiaire', taille: 20 },
                         { titre: 'Score attribué', taille: 10 },
                         { titre: 'Score possible de la question', taille: 10 }].freeze

    def initialize(partie:)
      super()
      @partie = partie
    end

    def to_xls
      entetes = @partie.situation.litteratie? ? ENTETES_LITTERATIE : ENTETES_NUMERATIE
      @sheet = ExportXls.new(entetes: entetes).sheet
      remplie_la_feuille
      retourne_le_contenu_du_xls
    end

    def nom_du_fichier
      evaluation = @partie.evaluation
      code_de_campagne = evaluation.campagne.code.parameterize
      nom_de_levaluation = evaluation.nom.parameterize.first(15)
      genere_fichier("#{nom_de_levaluation}-#{code_de_campagne}")
    end

    def regroupe_par_code_clea(evenements)
      evenements.group_by(&:code_clea)
    end

    private

    def remplie_la_feuille
      ligne = 1
      evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
      regroupe_par_code_clea(evenements_reponses).each do |code, evenements|
        ligne = remplis_reponses_par_code(ligne, code, evenements)
      end
      ligne
    end

    def remplis_reponses_par_code(ligne, code, evenements)
      if code.present?
        @sheet[ligne, 0] = "#{code} - score: #{pourcentage_reussite(evenements)}%"
        ligne += 1
      end
      remplis_reponses(ligne, evenements)
    end

    def pourcentage_reussite(evenements)
      scores = evenements.map { |e| [e.donnees['scoreMax'] || 0, e.donnees['score'] || 0] }
      score_max, score = scores.transpose.map(&:sum)
      score_max.zero? ? 0 : (score * 100 / score_max).round
    end

    def remplis_reponses(ligne, evenements)
      evenements.sort_by(&:position).each do |evenement|
        ligne = remplis_ligne(ligne, evenement)
      end
      ligne
    end

    def remplis_ligne(ligne, evenement)
      method = @partie.situation.litteratie? ? :remplis_litteratie : :remplis_numeratie
      send(method, ligne, evenement)
      ligne + 1
    end

    def remplis_litteratie(ligne, evenement)
      @sheet.row(ligne).replace([evenement.donnees['question'],
                                 evenement.donnees['intitule'],
                                 evenement.reponse_intitule,
                                 evenement.donnees['score'],
                                 evenement.donnees['scoreMax'],
                                 evenement.donnees['metacompetence']])
    end

    def remplis_numeratie(ligne, evenement)
      question = Question.find_by(nom_technique: evenement.donnees['question'])
      @sheet.row(ligne).replace([evenement.code_clea,
                                 evenement.donnees['question'],
                                 evenement.donnees['metacompetence']&.humanize,
                                 question&.interaction,
                                 evenement.donnees['intitule']])
      remplis_choix(ligne, evenement, question)
      remplis_score(ligne, evenement)
    end

    def remplis_score(ligne, evenement)
      @sheet[ligne, 8] = evenement.donnees['score']
      @sheet[ligne, 9] = evenement.donnees['scoreMax']
    end

    def remplis_choix(ligne, evenement, question)
      @sheet[ligne, 5] = question&.interaction == 'qcm' ? question&.liste_choix : nil
      @sheet[ligne, 6] = question&.bonnes_reponses if question&.qcm?
      @sheet[ligne, 6] = question&.bonne_reponse&.intitule if question&.saisie?
      @sheet[ligne, 7] = evenement.reponse_intitule
    end
  end
end
