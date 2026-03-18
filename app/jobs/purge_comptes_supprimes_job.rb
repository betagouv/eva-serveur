class PurgeComptesSupprimesJob < ApplicationJob
  queue_as :default

  def perform
    nb_anonymises = anonymise_comptes_avec_evaluations
    nb_purges = purge_comptes_sans_evaluations
    Rails.logger
      .info("[PurgeComptesSupprimesJob] #{nb_purges} supprimé(s), #{nb_anonymises} anonymisé(s)")
  end

  private

  def ids_comptes_avec_evaluations
    @ids_comptes_avec_evaluations ||= Campagne.with_deleted
            .joins("INNER JOIN evaluations ON evaluations.campagne_id = campagnes.id")
            .distinct
            .pluck(:compte_id)
  end

  def purge_comptes_sans_evaluations
    count = 0
    Compte.only_deleted.where.not(id: ids_comptes_avec_evaluations).find_each do |compte|
      Evaluation.with_deleted.where(responsable_suivi: compte).update_all(responsable_suivi_id: nil)
      Beneficiaire.with_deleted.where(compte: compte).update_all(compte_id: nil)
      Campagne.with_deleted.where(compte: compte).find_each(&:really_destroy!)
      compte.really_destroy!
      count += 1
    end
    count
  end

  def anonymise_comptes_avec_evaluations
    count = 0
    Compte.only_deleted.where(anonymise_le: nil).where(id: ids_comptes_avec_evaluations)
      .find_each do |compte|
        Anonymisation::Compte.new(compte).anonymise
        count += 1
    end
    count
  end
end
