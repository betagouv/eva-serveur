class ChangePrePositionnementEnDiagnostique < ActiveRecord::Migration[7.2]
  def up
    ParcoursType.where(type_de_programme: 'pre_positionnement').update(type_de_programme: 'diagnostique')
  end

  def down
    ParcoursType.where(type_de_programme: 'diagnostique').update(type_de_programme: 'pre_positionnement')
  end
end
