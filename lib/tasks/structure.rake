# frozen_string_literal: true

namespace :structure do
  desc 'Assigne les régions pour les structures sans région'
  task assigne_region: :environment do
    Structure::AssigneRegionJob.perform_now
  end

  desc 'Réassigne les régions des structures avec un code postal commençant par 21'
  task reassigne_region_corse: :environment do
    structures = Structure.where(region: 'Corse').where('code_postal LIKE ?', '21%')
    structures.find_each do |structure|
      structure.geocode
      structure.save
      p "assigne région \"#{structure.region}\" pour #{structure.nom}"
    end
  end
end
