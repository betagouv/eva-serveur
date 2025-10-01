class NotificationAdminComptesEnAttenteJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    comptes_en_attente = Compte.validation_en_attente
    structures = Structure.where(id: comptes_en_attente.select(:structure_id))
    admins = Compte.where(role: Compte::ADMIN_ROLES).where(structure_id: structures)

    admins.find_each do |admin|
      comptes = comptes_en_attente.where(structure_id: admin.structure_id)
      CompteMailer.with(compte_admin: admin, comptes: comptes)
                  .comptes_a_autoriser
                  .deliver_now
    end
  end
end
