class PersisteMetriquesPartieJob < ApplicationJob
  queue_as :default

  def perform(partie)
    restitution = FabriqueRestitution.instancie partie
    restitution.persiste
    PersisteRestitutionJob.perform_later(partie.evaluation)
  end
end
