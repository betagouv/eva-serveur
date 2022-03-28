# frozen_string_literal: true

module Restitution
  module Illettrisme
    TABLEAU_SEUILS = {
      'syntaxe_et_orthographe_7' => [24, 57],
      'syntaxe_et_orthographe_6' => [12, 25],
      'syntaxe_et_orthographe_5' => [17, 41],
      'syntaxe_et_orthographe_4' => [15, 34],
      'syntaxe_et_orthographe_3' => [22, 60],
      'syntaxe_et_orthographe_2' => [11, 24],
      'syntaxe_et_orthographe_1' => [15, 35],
      'multiplication_niveau2' => [55, 138],
      'numeratie_multiplication' => [40, 115],
      'numeratie_division' => [44, 115],
      'connaissance_et_comprehension_9' => [11, 23],
      'connaissance_et_comprehension_8' => [16, 35],
      'connaissance_et_comprehension_7' => [23, 46],
      'connaissance_et_comprehension_6' => [14, 41],
      'connaissance_et_comprehension_5' => [23, 51],
      'connaissance_et_comprehension_4' => [13, 28],
      'connaissance_et_comprehension_3' => [18, 37],
      'connaissance_et_comprehension_2' => [12, 29],
      'connaissance_et_comprehension_1' => [26, 69],
      'agenda' => [19, 40],
      'deverrouillage' => [40, 89],
      'fin1' => [16, 34],
      'fin2' => [22, 51],
      'fin3' => [8, 15],
      'heure-bureau-mickael' => [24, 49],
      'nombre-tours-de-manege' => [60, 148],
      'notes' => [13, 25],
      'ou-retrouver-dounia' => [28, 62],
      'photo' => [16, 32],
      'quel-bureau' => [36, 76],
      'quelle-salle-reserver' => [54, 118],
      'rappels' => [13, 22]
    }.freeze

    class ScoreQuestion
      def initialize(metrique_temps_questions)
        @metrique_temps_questions = metrique_temps_questions
      end

      def calcule(evenements, metacompetence)
        @metrique_temps_questions.calcule(evenements, metacompetence).map do |temps_question|
          succes = temps_question[:succes]
          temps = temps_question[:temps]
          seuils = recupere_seuils(temps_question[:question])

          if succes
            score_succes(temps, seuils)
          else
            score_echec(temps, seuils)
          end
        end
      end

      private

      def score_succes(temps, seuils)
        if temps <= seuils[0]
          3
        elsif temps > seuils[1]
          1
        else
          2
        end
      end

      def score_echec(temps, seuils)
        if temps <= seuils[0]
          -2
        elsif temps > seuils[1]
          0
        else
          -1
        end
      end

      def recupere_seuils(nom_question)
        seuils = TABLEAU_SEUILS[nom_question]
        raise nom_question if seuils.blank?

        seuils
      end
    end
  end
end
