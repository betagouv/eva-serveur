# frozen_string_literal: true

module Restitution
  module Positionnement
    class Export < ::ImportExport::ExportXls
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

      private

      def remplie_la_feuille
        ligne = 1
        if @partie.situation.litteratie?
          ligne = remplis_reponses_litteratie(ligne)
        elsif @partie.situation.numeratie?
          ligne = remplis_reponses_numeratie(ligne)
        end
        ligne
      end

      def remplis_reponses_litteratie(ligne)
        export = ExportLitteratie.new(@evenements_reponses.sort_by(&:position), @sheet)
        export.remplis_reponses(ligne)
      end

      def remplis_reponses_numeratie(ligne)
        export = ExportNumeratie.new(@partie, @sheet)
        export.regroupe_par_codes_clea.each do |code, sous_codes|
          ligne = remplis_par_sous_domaine(ligne, code, sous_codes, export)
        end
        ligne
      end

      def remplis_par_sous_domaine(ligne, code, sous_codes, export)
        reponses = sous_codes.values.flatten
        @sheet[ligne, 0] =
          "#{code} - #{Metacompetence::CODECLEA_INTITULES[code]} - " \
          "score: #{pourcentage_reussite(reponses)}"
        ligne += 1
        sous_codes.each do |sous_code, evenements|
          ligne = remplis_par_sous_sous_domaine(ligne, sous_code, evenements, export)
        end
        ligne
      end

      def remplis_par_sous_sous_domaine(ligne, sous_code, evenements, export)
        @sheet[ligne, 0] = "#{sous_code} - score: #{pourcentage_reussite(evenements)}"
        ligne += 1
        export.remplis_reponses(ligne, evenements)
      end

      def pourcentage_reussite(reponses)
        scores = reponses.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
        score_max, score = scores.transpose.map(&:sum)
        pourcentage = Pourcentage.new(valeur: score, valeur_max: score_max).calcul&.round
        score_max.zero? ? 'non applicable' : "#{pourcentage}%"
      end
    end
  end
end
