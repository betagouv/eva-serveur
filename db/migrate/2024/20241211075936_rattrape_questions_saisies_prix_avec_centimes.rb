class RattrapeQuestionsSaisiesPrixAvecCentimes < ActiveRecord::Migration[7.2]
  def up
    QuestionSaisie.where(type_saisie: 'prix_avec_centimes').update_all(reponse_placeholder: '0,00', suffix_reponse: '€')
  end
end
