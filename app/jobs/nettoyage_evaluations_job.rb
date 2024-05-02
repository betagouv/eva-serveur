# frozen_string_literal: true

class NettoyageEvaluationsJob < ApplicationJob
  queue_as :default

  def perform
    deleted_parties = Partie.only_deleted.where('deleted_at < :date', date: 1.month.ago)
    logger.info "suppression définitive de #{deleted_parties.count} parties"
    deleted_parties.find_each do |partie|
      logger.info "suppression définitive de la partie #{partie.id}"
      partie.really_destroy!
    end
  end
end
