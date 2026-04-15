class Structure
  class AssigneRegionJob < ApplicationJob
    queue_as :default

    def perform
      structures = Structure.where(region: nil).where.not(code_postal: nil)
      structures.find_each do |structure|
        structure.send(:geocodifie)
        structure.save
        Rails.logger.debug { "assigne région \"#{structure.region}\" pour #{structure.nom}" }
      end
    end
  end
end
