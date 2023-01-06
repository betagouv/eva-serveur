class ModifieModeTutorielDansCompte < ActiveRecord::Migration[7.0]
  def up
    Structure.activees.find_each do |structure|
      comptes = Compte.where(structure: structure).validation_acceptee
      comptes.update_all(mode_tutoriel: false)
    end
  end
end
