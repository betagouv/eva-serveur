# frozen_string_literal: true

module Restitution
  module Illettrisme
    class Synthetiseur
      attr_reader :algo

      def initialize(interpreteur_pre_positionnement, interpreteur_positionnement)
        @algo = if interpreteur_positionnement.present?
                  SynthetiseurPositionnement.new(interpreteur_positionnement)
                else
                  SynthetiseurPrePositionnement.new(interpreteur_pre_positionnement)
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
        def initialize(interpreteur_pre_positionnement)
          @interpreteur = interpreteur_pre_positionnement
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

      class SynthetiseurPositionnement
        def initialize(interpreteur_positionnement)
          @niveau_positionnement = interpreteur_positionnement.synthese[:niveau_litteratie]
        end

        def socle_clea?
          @niveau_positionnement.in?(%i[profil4 profil_4h profil_4h_plus profil_4h_plus_plus])
        end

        def illettrisme_potentiel?
          @niveau_positionnement.in?(%i[profil1 profil2])
        end

        def aberrant?
          @niveau_positionnement == :profil_aberrant
        end

        def indeterminee?
          @niveau_positionnement == :indetermine
        end
      end
    end
  end
end
