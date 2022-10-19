class MigreLesEvenementsReponse < ActiveRecord::Migration[6.0]
  class Evenement < ApplicationRecord; end

  def change
    Evenement.where(nom: 'reponse').find_each do |evenement|
      anciennes_donnees = evenement.donnees
      nouvelles_donnees = anciennes_donnees.clone
      if anciennes_donnees['question'].is_a? Integer
        nouvelles_donnees['question'] = Question.find(anciennes_donnees['question']).uuid
      end
      if anciennes_donnees['reponse'].is_a? Integer
        nouvelles_donnees['reponse'] = Choix.find(anciennes_donnees['reponse']).uuid
      end
      evenement.donnees = nouvelles_donnees
      evenement.save!(validate: false)
    end
  end
end
