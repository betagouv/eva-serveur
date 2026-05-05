class AssigneEtapeInscriptionCompletPourLesComptesExistants < ActiveRecord::Migration[7.2]
  def up
    Compte.update_all(etape_inscription: "complet")
  end

  def down
    Compte.update_all(etape_inscription: "nouveau")
  end
end
