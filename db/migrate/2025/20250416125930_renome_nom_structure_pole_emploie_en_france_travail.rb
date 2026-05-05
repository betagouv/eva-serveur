class RenomeNomStructurePoleEmploieEnFranceTravail < ActiveRecord::Migration[7.2]
  class StructureLocal < ApplicationRecord; end

  def up
    regexp = "p[oô]le\s+emploi"
    StructureLocale.where("nom ~* ?", regexp).find_each do |s|
      s.update(nom: s.nom.gsub(Regexp.new(regexp, Regexp::IGNORECASE), "France Travail"))
    end
  end

  def down
    regexp = "france travail"
    StructureLocale.where("nom ~* ?", regexp).find_each do |s|
      s.update(nom: s.nom.gsub(Regexp.new(regexp, Regexp::IGNORECASE), "Pôle Emploi"))
    end
  end
end
