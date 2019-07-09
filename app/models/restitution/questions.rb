# frozen_string_literal: true

module Restitution
  class Questions < Base
    EVENEMENT = {
      REPONSE: 'reponse'
    }.freeze

    def termine?
      reponses.size == 2
    end

    def reponses
      evenements.find_all { |e| e.nom == EVENEMENT[:REPONSE] }
    end
  end
end
