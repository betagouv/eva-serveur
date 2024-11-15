class ModifieModeTutorielDansCompte < ActiveRecord::Migration[7.0]
  def up
    structure_ids = Structure.activees.select(:id)
    comptes = Compte.where(structure_id: structure_ids).validation_acceptee
    comptes.update_all(mode_tutoriel: false)
  end
end
