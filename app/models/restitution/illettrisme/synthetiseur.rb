# frozen_string_literal: true

module Restitution
  module Illettrisme
    class Synthetiseur
      def initialize(interpreteur_pre_positionnement, interpreteur_positionnement, inter_numeratie)
        @algo_pre_positionnement =
          if interpreteur_pre_positionnement.present?
            SynthetiseurPrePositionnement.new(interpreteur_pre_positionnement)
          end
        @algo_positionnement =
          if interpreteur_positionnement.present?
            SynthetiseurPositionnement.new(interpreteur_positionnement, nil)
          end
        @algo_numeratie =
          (SynthetiseurPositionnement.new(nil, inter_numeratie) if inter_numeratie.present?)
      end

      def synthese
        synthese_positionnement.presence ||
          synthese_pre_positionnement ||
          synthese_positionnement_numeratie.presence
      end

      def synthese_positionnement
        Synthetiseur.calcule_synthese(@algo_positionnement)
      end

      def synthese_positionnement_numeratie
        Synthetiseur.calcule_synthese(@algo_numeratie)
      end

      def synthese_pre_positionnement
        Synthetiseur.calcule_synthese(@algo_pre_positionnement)
      end

      def positionnement_litteratie
        @algo_positionnement.niveau_positionnement if @algo_positionnement.present?
      end

      def positionnement_numeratie
        @algo_numeratie.niveau_numeratie if @algo_numeratie.present?
      end

      def self.calcule_synthese(algo)
        return if algo.blank? || algo.indetermine?
        return 'illettrisme_potentiel' if algo.illettrisme_potentiel?
        return 'socle_clea' if algo.socle_clea?
        return 'aberrant' if algo.aberrant?

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

        def indetermine?
          @interpreteur.interpretations_cefr[:litteratie].blank? and
            @interpreteur.interpretations_cefr[:numeratie].blank?
        end
      end

      class SynthetiseurPositionnement
        attr_reader :niveau_positionnement, :niveau_numeratie

        def initialize(interpreteur_positionnement, inter_numeratie)
          if interpreteur_positionnement
            @niveau_positionnement = interpreteur_positionnement.synthese[:niveau_litteratie]
          end
          return unless inter_numeratie

          @niveau_numeratie = inter_numeratie.synthese[:profil_numeratie]
        end

        def socle_clea?
          @niveau_positionnement.in?(%i[profil4 profil_4h profil_4h_plus
                                        profil_4h_plus_plus]) ||
            @niveau_numeratie.in?(%i[profil4 profil4_plus])
        end

        def illettrisme_potentiel?
          @niveau_positionnement.in?(%i[profil1
                                        profil2]) || @niveau_numeratie.in?(%i[profil1 profil2])
        end

        def aberrant?
          @niveau_positionnement == :profil_aberrant
        end

        def indetermine?
          @niveau_positionnement == :indetermine || @niveau_numeratie == :indetermine
        end
      end
    end
  end
end
