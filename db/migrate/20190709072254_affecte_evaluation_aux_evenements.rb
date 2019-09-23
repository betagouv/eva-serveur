class AffecteEvaluationAuxEvenements < ActiveRecord::Migration[5.2]
  def change
    Evenement.unscoped.select(:utilisateur).distinct.each do |evenement|
      next if evenement.utilisateur.nil?
      evaluation = Evaluation.create(nom: evenement.utilisateur)
      Evenement.where(utilisateur: evenement.utilisateur).update_all(evaluation_id: evaluation.id)
    end
  end
end
