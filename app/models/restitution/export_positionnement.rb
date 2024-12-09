# frozen_string_literal: true

module Restitution
  class ExportPositionnement < ::ImportExport::ExportXls
    def initialize(partie:)
      super()
      @partie = partie
      @evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
    end

    def to_xls
      entetes = ImportExport::Positionnement::ExportDonnees.new(@partie).entetes
      @sheet = ::ImportExport::ExportXls.new(entetes: entetes).sheet
      remplie_la_feuille
      retourne_le_contenu_du_xls
    end

    def nom_du_fichier
      evaluation = @partie.evaluation
      code_de_campagne = evaluation.campagne.code.parameterize
      nom_de_levaluation = evaluation.nom.parameterize.first(15)
      genere_fichier("#{nom_de_levaluation}-#{code_de_campagne}")
    end

    def regroupe_par_code_clea
      repondues_et_non_repondues(questions_non_repondues.map(&:as_json),
                                 @evenements_reponses.map(&:donnees))
        .group_by do |e|
        Metacompetence.code_clea(e['metacompetence'])
      end
    end

    def questions_non_repondues
      questionnaire = Questionnaire.find_by(id: @partie.situation.questionnaire)
      return [] unless questionnaire&.questions

      questionnaire.questions.reject do |q|
        @evenements_reponses.questions_repondues.include?(q[:nom_technique]) ||
          q[:nom_technique].start_with?('N1R', 'N2R', 'N3R') || q.sous_consigne?
      end
    end

    def repondues_et_non_repondues(non_repondues, repondues)
      non_repondues.each do |q|
        q['scoreMax'] = q.delete('score')
        q['question'] = q.delete('nom_technique')
      end
      repondues + non_repondues
    end

    private

    def remplie_la_feuille
      ligne = 1
      if @partie.situation.litteratie?
        ligne = remplis_reponses(ligne, @evenements_reponses.sort_by(&:position))
      else
        regroupe_par_code_clea.each do |code, evenements|
          ligne = remplis_reponses_par_code(ligne, evenements, code)
        end
      end
      ligne
    end

    def remplis_reponses_par_code(ligne, evenements, code = nil)
      @sheet[ligne, 0] = "#{code} - score: #{pourcentage_reussite(evenements)}"
      ligne += 1
      remplis_reponses(ligne, evenements)
    end

    def pourcentage_reussite(evenements)
      scores = evenements.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
      score_max, score = scores.transpose.map(&:sum)
      score_max.zero? ? 'non applicable' : "#{(score * 100 / score_max).round}%"
    end

    def remplis_reponses(ligne, evenements)
      evenements.each do |evenement|
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

    def remplis_numeratie(ligne, donnees)
      question = Question.find_by(nom_technique: donnees['question'])
      @sheet.row(ligne).replace([Metacompetence.code_clea(donnees['metacompetence']),
                                 donnees['question'],
                                 donnees['metacompetence']&.humanize,
                                 question&.interaction,
                                 donnees['intitule']])
      remplis_choix(ligne, donnees['reponse'], question)
      remplis_score(ligne, donnees)
    end

    def remplis_score(ligne, evenement)
      @sheet[ligne, 8] = evenement['score'].to_s
      @sheet[ligne, 9] = evenement['scoreMax'].to_s
    end

    def remplis_choix(ligne, intitule, question)
      @sheet[ligne, 5] = question&.interaction == 'qcm' ? question&.liste_choix : nil
      @sheet[ligne, 6] = question&.bonnes_reponses if question&.qcm? || question&.saisie?
      @sheet[ligne, 7] = intitule
    end
  end
end
