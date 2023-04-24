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
      puts "assigne région \"#{structure.region}\" pour #{structure.nom}"
    end
  end

  desc 'Vérifie les regions avec le nouvel algo'
  task verifie_region: :environment do
    logger = RakeLogger.logger
    cps = Structure.group(:code_postal, :region).pluck(:code_postal, :region)
    total = cps.count
    logger.info "Nombre de Structure : #{total}"

    count = 0
    cps.each do |cp, ancienne_region|
      print '.'

      nouvelle_region = GeolocHelper.cherche_region(cp)
      if ancienne_region != nouvelle_region
        puts "\nanciennement \"#{ancienne_region}\" nouvelle \"#{nouvelle_region}\" : #{cp}"
      end
      count += 1
    end
    logger.info "C'est fini"
  end
end
