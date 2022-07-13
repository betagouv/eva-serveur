# frozen_string_literal: true

namespace :structure do
  desc 'Assigne les régions pour les structures sans région'
  task assigne_region: :environment do
    structures = Structure.where(region: nil).where.not(code_postal: nil)
    structures.find_each do |structure|
      structure.geocode
      structure.save
      puts "assigne région \"#{structure.region}\" pour #{structure.nom}"
    end
  end
end
