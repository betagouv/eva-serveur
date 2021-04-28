# frozen_string_literal: true

namespace :structure do
  desc 'Assigne les régions pour les structures sans région'
  task assigne_region: :environment do
    Structure.where(region: nil).find_each do |structure|
      resultats = Geocoder.search("#{structure.code_postal} FRANCE")
      if (resultat = resultats.first)
        structure.update(region: resultat.state)
        puts "assigne région #{resultat.state} pour #{structure.nom}"
      end
    end
  end
end
