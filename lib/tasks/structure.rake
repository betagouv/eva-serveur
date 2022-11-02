# frozen_string_literal: true

namespace :structure do
  desc 'Assigne les régions pour les structures sans région'
  task assigne_region: :environment do
    Structure::AssigneRegionJob.perform_now
  end

  desc 'Migre la colonne structure_referente vers la colonne ancestry'
  task migre_structure_referente_id_vers_ancestry: :environment do
    Structure.build_ancestry_from_parent_ids!
    Structure.check_ancestry_integrity!
  end
end
