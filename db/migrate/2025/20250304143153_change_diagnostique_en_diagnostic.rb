class ChangeDiagnostiqueEnDiagnostic < ActiveRecord::Migration[7.2]
  def up
    ParcoursType.where(type_de_programme: 'diagnostique').update(type_de_programme: 'diagnostic')
  end

  def down
    ParcoursType.where(type_de_programme: 'diagnostic').update(type_de_programme: 'diagnostique')
  end
end
