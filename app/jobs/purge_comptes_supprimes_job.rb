class PurgeComptesSupprimesJob < ApplicationJob
  queue_as :default

  def perform
    purge_comptes_sans_evaluations
    anonymise_comptes_avec_evaluations
  end

  private

  def ids_comptes_avec_evaluations
    @ids_comptes_avec_evaluations ||= Campagne.with_deleted
            .joins("INNER JOIN evaluations ON evaluations.campagne_id = campagnes.id")
            .distinct
            .pluck(:compte_id)
  end

  def purge_comptes_sans_evaluations
    Compte.only_deleted.where.not(id: ids_comptes_avec_evaluations).find_each do |compte|
      Campagne.with_deleted.where(compte: compte).find_each(&:really_destroy!)
      compte.really_destroy!
    end
  end

  def anonymise_comptes_avec_evaluations
    Compte.only_deleted.where(anonymise_le: nil).where(id: ids_comptes_avec_evaluations)
      .find_each do |compte|
        Anonymisation::Compte.new(compte).anonymise
    end
  end
end
