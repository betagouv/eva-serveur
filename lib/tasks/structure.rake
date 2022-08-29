# frozen_string_literal: true

namespace :structure do
  desc 'Assigne les régions pour les structures sans région'
  task assigne_region: :environment do
    Structure::AssigneRegionJob.perform_now
  end
end
