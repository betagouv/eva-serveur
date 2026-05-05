class ConvertiNomTechniqueDesSituations < ActiveRecord::Migration[7.2]
  def up
    Situation.find_each do |situation|
      if situation.nom_technique.include?('-')
        nouvelle_valeur = situation.nom_technique.gsub('-', '_')
        situation.update(nom_technique: nouvelle_valeur)
      end
    end
  end

  def down; end
end
