class RenommePrixAvecCentimesEnNombreAvecVirguleSurQuestionsSaisie < ActiveRecord::Migration[7.2]
  def up
    QuestionSaisie.where(type_saisie: 'prix_avec_centimes').update_all(type_saisie: 'nombre_avec_virgule', suffix_reponse: '€')
  end

  def down
    QuestionSaisie.where(type_saisie: 'nombre_avec_virgule').update_all(type_saisie: 'prix_avec_centimes')
  end
end
