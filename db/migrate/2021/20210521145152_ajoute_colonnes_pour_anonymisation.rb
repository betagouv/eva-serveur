class AjouteColonnesPourAnonymisation < ActiveRecord::Migration[6.1]
  def change
    add_column :evaluations, :anonymise_le, :datetime
    add_column :comptes, :anonymise_le, :datetime
    add_column :campagnes, :anonymise_le, :datetime
    add_column :structures, :anonymise_le, :datetime
  end
end
