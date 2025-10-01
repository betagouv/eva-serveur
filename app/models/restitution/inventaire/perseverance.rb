module Restitution
  class Inventaire
    class Perseverance < Restitution::Competence::Base
      def niveau
        if @restitution.reussite?
          niveau_restitution_reussie
        elsif un_essai || essai_avec_de_bonnes_reponses_en_moins_22_min
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def niveau_restitution_reussie
        if @restitution.temps_total > 22.minutes.to_i
          ::Competence::NIVEAU_4
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def un_essai
        @restitution.nombre_essais_validation == 1
      end

      def essai_avec_de_bonnes_reponses_en_moins_22_min
        @restitution.nombre_essais_validation.positive? &&
          @restitution.essais_verifies.last.nombre_erreurs < 8 &&
          @restitution.temps_total < 22.minutes.to_i
      end
    end
  end
end
