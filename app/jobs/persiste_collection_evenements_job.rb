# frozen_string_literal: true

class PersisteCollectionEvenementsJob < ApplicationJob
  queue_as :default

  def perform(evaluation_id, evenements)
    evenements.each do |parametres|
      parametres.merge!(evaluation_id: evaluation_id)
      FabriqueEvenement.new(parametres).call
    end
  end
end
