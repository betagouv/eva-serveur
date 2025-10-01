module Restitution
  class Inventaire
    class ComprehensionConsigne < Restitution::Competence::Base
      def niveau
        if @restitution.reussite?
          ::Competence::NIVEAU_4
        elsif @restitution.abandon? &&
              (un_essai_avec_8_erreurs || @restitution.nombre_rejoue_consigne >= 2)
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def un_essai_avec_8_erreurs
        @restitution.nombre_essais_validation == 1 &&
          @restitution.essais_verifies.first.nombre_erreurs == 8
      end
    end
  end
end
