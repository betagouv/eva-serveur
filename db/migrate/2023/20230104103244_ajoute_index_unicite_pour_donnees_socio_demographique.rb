class AjouteIndexUnicitePourDonneesSocioDemographique < ActiveRecord::Migration[7.0]

  # si jamais l'index ne passe pas, il faut lancer la tache rake : "rails donnees_socio_demographique:supprimer_doublons"
  def change
    remove_index :donnees_sociodemographiques, :evaluation_id
    add_index :donnees_sociodemographiques, :evaluation_id, unique: true
  end
end
