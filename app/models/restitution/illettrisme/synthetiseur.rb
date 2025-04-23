# frozen_string_literal: true

module Restitution
  module Illettrisme
    class Synthetiseur
      def initialize(interpreteur_diagnostic, inter_litteratie, inter_numeratie)
        @algo_diagnostic =
          (SynthetiseurDiagnostic.new(interpreteur_diagnostic) if interpreteur_diagnostic.present?)
        @algo_positionnement_litteratie =
          (SynthetiseurPositionnement.new(inter_litteratie, nil) if inter_litteratie.present?)
        @algo_positionnement_numeratie =
          (SynthetiseurPositionnement.new(nil, inter_numeratie) if inter_numeratie.present?)
      end

      def synthese
          synthese_positionnement || synthese_diagnostic
      end

      def synthese_positionnement_litteratie
        Synthetiseur.calcule_synthese([ @algo_positionnement_litteratie ])
      end

      def synthese_positionnement_numeratie
        Synthetiseur.calcule_synthese([ @algo_positionnement_numeratie ])
      end

      def synthese_positionnement
        Synthetiseur.calcule_synthese([ @algo_positionnement_litteratie,
                                        @algo_positionnement_numeratie ])
      end

      def synthese_diagnostic
        Synthetiseur.calcule_synthese([ @algo_diagnostic ])
      end

      def positionnement_litteratie
        if @algo_positionnement_litteratie.present?
          @algo_positionnement_litteratie.niveau_positionnement
        end
      end

      def positionnement_numeratie
        @algo_positionnement_numeratie.niveau_numeratie if @algo_positionnement_numeratie.present?
      end

      def self.calcule_synthese(algos)
        algos.reject! { |objet| objet.blank? || objet.indetermine? }
        return if algos.empty?
        return "illettrisme_potentiel" if algos.any? &:illettrisme_potentiel?
        return "socle_clea" if algos.all? &:socle_clea?
        return "aberrant" if algos.all? &:aberrant?

        "ni_ni"
      end

      class SynthetiseurDiagnostic
        def initialize(interpreteur_diagnostic)
          @interpreteur = interpreteur_diagnostic
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

        def initialize(inter_litteratie, inter_numeratie)
          @niveau_positionnement = inter_litteratie.synthese[:niveau_litteratie] if inter_litteratie
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
