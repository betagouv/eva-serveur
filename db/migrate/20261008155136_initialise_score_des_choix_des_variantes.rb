class InitialiseScoreDesChoixDesVariantes < ActiveRecord::Migration[8.0]
  # Q2PC01__BTP est une variante de Q2PC01
  SEPARATEUR_VARIANTE = "__".freeze

  def up
    variantes.find_each do |variante|
      reference = Question.find_by(nom_technique: nom_technique_reference(variante.nom_technique))
      next unless reference

      recopie_scores(reference, variante)
    end
  end

  def down
    Choix.where(question_id: variantes.select(:id)).update_all(score: nil)
  end

  private

  def recopie_scores(reference, variante)
    scores = Choix.where(question_id: reference.id).where.not(score: nil)
                  .pluck(:nom_technique, :score).to_h
    Choix.where(question_id: variante.id).find_each do |choix|
      score = scores[nom_technique_reference(choix.nom_technique)]
      choix.update_columns(score: score) if score
    end
  end

  def variantes
    Question.where("nom_technique LIKE ?",
                   "%#{ActiveRecord::Base.sanitize_sql_like(SEPARATEUR_VARIANTE)}%")
  end

  def nom_technique_reference(nom_technique)
    nom_technique.to_s.split(SEPARATEUR_VARIANTE).first
  end
end
