module Restitution
  class Inventaire
    class VigilanceControle < Restitution::Competence::Base
      def niveau
        if @restitution.reussite?
          niveau_reussite
        elsif @restitution.abandon? && plus_2_essais_avec_meme_erreurs
          ::Competence::NIVEAU_1
        else
          ::Competence::NIVEAU_INDETERMINE
        end
      end

      def niveau_reussite
        if nombre_essais_sans_prise_en_main == 1
          ::Competence::NIVEAU_4
        elsif maximum_2_erreurs_rectifie_en_2_essais_sauf_non_remplissage
          ::Competence::NIVEAU_3
        else
          ::Competence::NIVEAU_2
        end
      end

      def essais_sans_prise_en_main
        essais_verifies = @restitution.essais_verifies
        premier_essai_prise_en_main? ? essais_verifies[1..] : essais_verifies
      end

      def nombre_essais_sans_prise_en_main
        essais_sans_prise_en_main.size
      end

      def premier_essai_prise_en_main?
        premier_essai = @restitution.essais_verifies.first
        premier_essai && premier_essai.nombre_de_non_remplissage >= 7
      end

      def essais_avec_erreurs_sauf_non_remplissage
        essais_sans_prise_en_main.select do |essai|
          essai.nombre_erreurs_sauf_de_non_remplissage.positive?
        end
      end

      def maximum_2_erreurs_rectifie_en_2_essais_sauf_non_remplissage
        essais_avec_erreurs = essais_avec_erreurs_sauf_non_remplissage
        essais_avec_erreurs.empty? ||
          (essais_avec_erreurs.size <= 2 &&
           essais_avec_erreurs.first.nombre_erreurs_sauf_de_non_remplissage <= 2)
      end

      def plus_2_essais_avec_meme_erreurs
        nombre_essais_sans_prise_en_main >= 2 &&
          essais_sans_prise_en_main.map(&:nombre_erreurs).uniq.size == 1
      end
    end
  end
end
