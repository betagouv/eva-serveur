# Construit l'objet des syntheses Eva Pro pour l'index (et l'export XLS)
# des evaluations, a partir des parties deja persistees (sans FabriqueRestitution).
class SynthesesEvaproPourIndex
  def self.pour(collection)
    new(collection).construire
  end

  def initialize(collection)
    @collection = collection
  end

  def construire
    return {} if ids_evaluations.empty?

    parties_par_evaluation.each_with_object(initialise_resultat) do |partie, resultat|
      ajoute_synthese_si_pertinent(partie, resultat)
    end
  end

  private

  def ids_evaluations
    @ids_evaluations ||= @collection.pluck(:id)
  end

  def parties_par_evaluation
    Partie.where(evaluation_id: ids_evaluations)
          .includes(:situation)
          .order(created_at: :desc)
  end

  def initialise_resultat
    ids_evaluations.index_with do |_|
      {
        pourcentage_risque: nil,
        score_cout: nil,
        synthese_impact: {}
      }
    end
  end

  def ajoute_synthese_si_pertinent(partie, resultat)
    nom_situation = partie.situation.nom_technique
    return unless situation_evapro?(nom_situation)

    ligne = resultat[partie.evaluation_id]
    return if ligne.nil?

    ajoute_pourcentage_risque_si_necessaire(ligne, nom_situation, partie)
    ajoute_synthese_impact_si_necessaire(ligne, nom_situation, partie)
  end

  def ajoute_pourcentage_risque_si_necessaire(ligne, nom_situation, partie)
    return unless diag_risques?(nom_situation)
    return unless ligne[:pourcentage_risque].nil?

    ligne[:pourcentage_risque] = extrait_pourcentage_risque(partie)
  end

  def ajoute_synthese_impact_si_necessaire(ligne, nom_situation, partie)
    return unless evaluation_impact_general?(nom_situation)
    return unless ligne[:synthese_impact].blank?

    ligne[:synthese_impact] = extrait_synthese_impact(partie)
    ligne[:score_cout] = extrait_score_cout(partie)
  end

  def situation_evapro?(nom_situation)
    diag_risques?(nom_situation) || evaluation_impact_general?(nom_situation)
  end

  def diag_risques?(nom_situation)
    nom_situation == Situation::DIAG_RISQUES_ENTREPRISE
  end

  def evaluation_impact_general?(nom_situation)
    nom_situation == Situation::EVALUATION_IMPACT_GENERAL
  end

  def extrait_pourcentage_risque(partie)
    synthese = partie.synthese || {}
    synthese["pourcentage_risque"] || synthese[:pourcentage_risque]
  end

  def extrait_score_cout(partie)
    synthese = partie.synthese || {}
    (synthese["score_cout"] || synthese[:score_cout])&.to_s
  end

  def extrait_synthese_impact(partie)
    (partie.synthese || {}).with_indifferent_access
  end
end
