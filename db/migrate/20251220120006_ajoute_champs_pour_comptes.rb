class AjouteChampsPourComptes < ActiveRecord::Migration[7.2]
  def change
    add_column :comptes, :fonction, :string
    add_column :comptes, :service_departement, :string
  end
end
