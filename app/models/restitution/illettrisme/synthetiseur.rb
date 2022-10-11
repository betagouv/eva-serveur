# frozen_string_literal: true

module Restitution
  module Illettrisme
    class Synthetiseur
      attr_reader :algo

      def initialize(interpreteur_pre_positionement, interpreteur_evaluation_avancee)
        @algo = if interpreteur_evaluation_avancee.present?
                  SynthetiseurEvaluationAvancee.new(interpreteur_evaluation_avancee)
                else
                  SynthetiseurPrePositionnement.new(interpreteur_pre_positionement)
                end
      end

      def synthese
        return 'illettrisme_potentiel' if algo.illettrisme_potentiel?
        return 'socle_clea' if algo.socle_clea?
        return 'aberrant' if algo.aberrant?
        return if algo.indeterminee?

        'ni_ni'
      end

      class SynthetiseurPrePositionnement
        def initialize(interpreteur_pre_positionement)
          @interpreteur = interpreteur_pre_positionement
        end

        def socle_clea?
          @interpreteur.interpretations_cefr[:litteratie] == :B1 and
            @interpreteur.interpretations_cefr[:numeratie] == :Y1
        end

        def illettrisme_potentiel?
          @interpreteur.interpretations_cefr[:litteratie] == :pre_A1 or
            @interpreteur.interpretations_cefr[:numeratie] == :pre_X1
        end

        def aberrant?
          false
        end

        def indeterminee?
          @interpreteur.interpretations_cefr[:litteratie].blank? and
            @interpreteur.interpretations_cefr[:numeratie].blank?
        end
      end

      class SynthetiseurEvaluationAvancee
        def initialize(interpreteur_evaluation_avancee)
          @niveau_avance = interpreteur_evaluation_avancee.synthese[:niveau_litteratie]
        end

        def socle_clea?
          @niveau_avance.in?(%i[profil4 profil_4h profil_4h_plus profil_4h_plus_plus])
        end

        def illettrisme_potentiel?
          @niveau_avance.in?(%i[profil1 profil2])
        end

        def aberrant?
          @niveau_avance == :profil_aberrant
        end

        def indeterminee?
          @niveau_avance == :indetermine
        end
      end
    end
  end
end
