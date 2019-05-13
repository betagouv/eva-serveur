# frozen_string_literal: true

module Evaluation
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
        @evenements.last.date - @date_depart_situation
      end

      def nombre_erreurs
        return nil unless @evenements.last.nom == EVENEMENT[:SAISIE_INVENTAIRE]

        @evenements.last.donnees['reponses'].inject(0) do |nombre_erreurs, (_id, reponse)|
          nombre_erreurs += 1 unless reponse['reussite']
          nombre_erreurs
        end
      end
    end

    def reussite?
      @evenements.last.nom == EVENEMENT[:SAISIE_INVENTAIRE] &&
        @evenements.last.donnees['reussite']
    end
    alias termine? reussite?

    def en_cours?
      @evenements.last.nom != EVENEMENT[:SAISIE_INVENTAIRE] && !abandon?
    end

    def nombre_ouverture_contenant
      compte_nom_evenements(EVENEMENT[:OUVERTURE_CONTENANT])
    end

    def nombre_essais_validation
      compte_nom_evenements(EVENEMENT[:SAISIE_INVENTAIRE])
    end

    def essais
      essais = @evenements.chunk_while do |evenement_avant, _|
        evenement_avant.nom != EVENEMENT[:SAISIE_INVENTAIRE]
      end
      date_depart = @evenements.first.date
      essais.map do |evenements|
        Essai.new(evenements, date_depart)
      end
    end

    def competences
      {
        ::Competence::COMPREHENSION_CONSIGNE => Inventaire::ComprehensionConsigne,
        ::Competence::ORGANISATION_METHODE => Inventaire::OrganisationMethode,
        ::Competence::RAPIDITE => Inventaire::Rapidite
      }.each_with_object({}) do |(competence, classe), resultat|
        resultat[competence] = classe.new(self).niveau
      end
    end
  end
end
