class AffecteLesSituationsAuxEvenements < ActiveRecord::Migration[5.2]
  class Evenement < ApplicationRecord
    belongs_to :situation
  end

  def change
    Evenement.find_each do |evenement|
      nom_technique = evenement['situation']
      situation = Situation.where(nom_technique: nom_technique).first_or_create do |situation|
        situation.libelle = nom_technique
      end
      evenement.situation = situation
      evenement.save(validate: false)
    end
  end
end
