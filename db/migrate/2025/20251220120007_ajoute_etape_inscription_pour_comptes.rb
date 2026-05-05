class AjouteEtapeInscriptionPourComptes < ActiveRecord::Migration[7.2]
  def change
    add_column :comptes, :etape_inscription, :string, default: "nouveau"
  end
end
