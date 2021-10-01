class LieUneCampagneAUnCompte < ActiveRecord::Migration[5.2]
  def change
    add_reference :campagnes, :compte, foreign_key: true
  end
end
