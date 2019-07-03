# frozen_string_literal: true

module Restitution
  class Inventaire < Base
    EVENEMENT = {
      OUVERTURE_CONTENANT: 'ouvertureContenant',
      SAISIE_INVENTAIRE: 'saisieInventaire'
    }.freeze

    class Essai < Inventaire
      def initialize(evenements, date_depart_situation)
        super(evenements)
        @date_depart_situation = date_depart_situation
      end

      def temps_total
        evenements.last.date - @date_depart_situation
      end

      def nombre_erreurs
        compte_reponse { |reponse| reponse['reussite'] }
      end

      def nombre_de_non_remplissage
        compte_reponse { |reponse| reponse['quantite'].present? }
      end

      def nombre_erreurs_sauf_de_non_remplissage
        return nil unless dernier_evenement_est_une_saisie_inventaire?

        nombre_erreurs - nombre_de_non_remplissage
      end

      def compte_reponse
        return nil unless dernier_evenement_est_une_saisie_inventaire?

        evenements.last.donnees['reponses'].inject(0) do |compteur, (_id, reponse)|
          compteur += 1 unless yield reponse
          compteur
        end
      end
    end

    def reussite?
      dernier_evenement_est_une_saisie_inventaire? &&
        evenements.last.donnees['reussite']
    end
    alias termine? reussite?

    def en_cours?
      !dernier_evenement_est_une_saisie_inventaire? && !abandon?
    end

    def nombre_ouverture_contenant
      compte_nom_evenements(EVENEMENT[:OUVERTURE_CONTENANT])
    end

    def nombre_essais_validation
      compte_nom_evenements(EVENEMENT[:SAISIE_INVENTAIRE])
    end

    def dernier_evenement_est_une_saisie_inventaire?
      evenements.last.nom == EVENEMENT[:SAISIE_INVENTAIRE]
    end

    def essais_verifies
      dernier_evenement_est_une_saisie_inventaire? ? essais : essais[0...-1]
    end

    def essais
      evenements_par_essais = evenements.chunk_while do |evenement_avant, _|
        evenement_avant.nom != EVENEMENT[:SAISIE_INVENTAIRE]
      end
      date_depart = evenements.first.date
      evenements_par_essais.map do |evenements|
        Essai.new(evenements, date_depart)
      end
    end

    def competences
      calcule_competences(
        ::Competence::PERSEVERANCE => Inventaire::Perseverance,
        ::Competence::COMPREHENSION_CONSIGNE => Inventaire::ComprehensionConsigne,
        ::Competence::RAPIDITE => Inventaire::Rapidite,
        ::Competence::VIGILANCE_CONTROLE => Inventaire::VigilanceControle,
        ::Competence::ORGANISATION_METHODE => Inventaire::OrganisationMethode
      )
    end
  end
end
