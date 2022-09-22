class AjouteParcoursTypeCategories < ActiveRecord::Migration[7.0]
  def up
    [
      'Pré-positionnement',
      'Évaluation avancée',
    ].each do |nom|
      ParcoursTypeCategorie.find_or_create_by!(nom: nom)
    end
  end
end
