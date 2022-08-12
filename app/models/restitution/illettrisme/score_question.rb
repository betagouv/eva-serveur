# frozen_string_literal: true

module Restitution
  module Illettrisme
    TABLEAU_SEUILS = {
      'syntaxe_et_orthographe_7' => [18, 28],
      'syntaxe_et_orthographe_6' => [9, 12],
      'syntaxe_et_orthographe_5' => [11, 17],
      'syntaxe_et_orthographe_4' => [11, 17],
      'syntaxe_et_orthographe_3' => [13, 19],
      'syntaxe_et_orthographe_2' => [9, 12],
      'syntaxe_et_orthographe_1' => [10, 15],
      'multiplication_niveau2' => [39, 56],
      'numeratie_multiplication' => [28, 38],
      'numeratie_division' => [28, 41],
      'connaissance_et_comprehension_9' => [8, 11],
      'connaissance_et_comprehension_8' => [12, 15],
      'connaissance_et_comprehension_7' => [18, 25],
      'connaissance_et_comprehension_6' => [9, 13],
      'connaissance_et_comprehension_5' => [16, 23],
      'connaissance_et_comprehension_4' => [10, 15],
      'connaissance_et_comprehension_3' => [15, 20],
      'connaissance_et_comprehension_2' => [8, 11],
      'connaissance_et_comprehension_1' => [18, 25],
      'agenda' => [17, 23],
      'deverrouillage' => [31, 46],
      'fin1' => [14, 20],
      'fin2' => [22, 33],
      'fin3' => [7, 10],
      'heure-bureau-mickael' => [21, 29],
      'nombre-tours-de-manege' => [45, 67],
      'notes' => [11, 16],
      'ou-retrouver-dounia' => [25, 34],
      'photo' => [14, 19],
      'quel-bureau' => [31, 79],
      'quelle-salle-reserver' => [46, 65],
      'rappels' => [11, 16] # ancien nom de l'application 'notes'
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
