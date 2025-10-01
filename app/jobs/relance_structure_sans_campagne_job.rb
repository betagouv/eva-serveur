class RelanceStructureSansCampagneJob < ApplicationJob
  queue_as :default

  def perform(structure_id)
    return unless Structure.sans_campagne.exists?(id: structure_id)

    admins = Compte.where(structure_id: structure_id).admin
    admins.each do |admin|
      StructureMailer.with(compte_admin: admin)
                     .relance_creation_campagne
                     .deliver_now
    end
  end
end
