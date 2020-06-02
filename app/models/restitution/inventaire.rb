# frozen_string_literal: true

module Restitution
  class Inventaire < Base
    EVENEMENT = {
      OUVERTURE_CONTENANT: 'ouvertureContenant',
      SAISIE_INVENTAIRE: 'saisieInventaire',
      FIN_SITUATION: 'finSituation'
    }.freeze

    class Essai < Inventaire
      def initialize(campagne, evenements, date_depart_situation)
        super(campagne, evenements)
        @date_depart_situation = date_depart_situation
      end

      def temps_total
        evenements.last.date - @date_depart_situation
      end

      def nombre_erreurs
        compte_reponse { |reponse| !reponse['reussite'] }
      end

      def nombre_de_non_remplissage
        compte_reponse { |reponse| !reponse['quantite'].present? }
      end

      def nombre_erreurs_sauf_de_non_remplissage
        return nil if nombre_erreurs.nil?

        nombre_erreurs - nombre_de_non_remplissage
      end

      def verifie?
        evenements.last.donnees['reponses']
      end

      def reussite?
        evenements.last.donnees['reussite']
      end

      def compte_reponse
        return nil unless verifie?

        evenements.last.donnees['reponses'].inject(0) do |compteur, (_id, reponse)|
          compteur += 1 if yield reponse
          compteur
        end
      end
    end

    alias reussite? termine?

    def en_cours?
      !(termine? || abandon?)
    end

    def nombre_ouverture_contenant
      compte_nom_evenements(EVENEMENT[:OUVERTURE_CONTENANT])
    end

    def nombre_essais_validation
      compte_nom_evenements(EVENEMENT[:SAISIE_INVENTAIRE])
    end

    def essais_verifies
      essais.last.verifie? ? essais : essais[0...-1]
    end

    def essais
      evenements_sans_la_fin = evenements.to_a.delete_if { |e| e.nom == EVENEMENT[:FIN_SITUATION] }
      evenements_par_essais = evenements_sans_la_fin.chunk_while do |evenement_avant, _|
        evenement_avant.nom != EVENEMENT[:SAISIE_INVENTAIRE]
      end
      date_depart = evenements.first.date
      evenements_par_essais.map do |evenements|
        Essai.new(campagne, evenements, date_depart)
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
