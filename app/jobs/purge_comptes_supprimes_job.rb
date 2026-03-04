class PurgeComptesSupprimesJob < ApplicationJob
  queue_as :default

  def perform
    comptes_a_purger.find_each do |compte|
      Campagne.with_deleted.where(compte: compte).find_each(&:really_destroy!)
      compte.really_destroy!
    end
  end

  private

  def comptes_a_purger
    Compte.only_deleted
          .where.not(
            id: Campagne.with_deleted
                        .joins("INNER JOIN evaluations ON evaluations.campagne_id = campagnes.id")
                        .select(:compte_id)
          )
  end
end
