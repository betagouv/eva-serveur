class AjouteEtapePriseEnMainPourComptes < ActiveRecord::Migration[7.0]
  def change
    add_column :comptes, :etape_prise_en_main, :string, default: 'creation_campagne'
  end
end
