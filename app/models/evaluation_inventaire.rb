# frozen_string_literal: true

class EvaluationInventaire < EvaluationBase
  EVENEMENT = {
    OUVERTURE_CONTENANT: 'ouvertureContenant',
    SAISIE_INVENTAIRE: 'saisieInventaire'
  }.freeze

  class Essai < EvaluationInventaire
    def initialize(evenements, date_depart_situation)
      super(evenements)
      @date_depart_situation = date_depart_situation
    end

    def temps_total
      @evenements.last.date - @date_depart_situation
    end
  end

  def reussite?
    @evenements.last.nom == EVENEMENT[:SAISIE_INVENTAIRE] &&
      @evenements.last.donnees['reussite']
  end

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
end
