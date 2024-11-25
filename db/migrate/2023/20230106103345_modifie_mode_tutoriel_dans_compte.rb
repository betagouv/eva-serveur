class ModifieModeTutorielDansCompte < ActiveRecord::Migration[7.0]
  class Compte < ApplicationRecord
    attribute :statut_validation, :integer
    enum :statut_validation, { en_attente: 0, acceptee: 1, refusee: 2 }, prefix: :validation
  end

  def up
    structure_ids = Structure.activees.select(:id)
    comptes = Compte.where(structure_id: structure_ids).validation_acceptee
    comptes.update_all(mode_tutoriel: false)
  end
end
