# frozen_string_literal: true

module Restitution
  class Securite
    class SecuriteHelper
      class << self
        def filtre_par_danger(evenements, &block)
          evenements.select(&block).group_by { |e| e.donnees['danger'] }.sort.to_h
        end
      end
    end
  end
end
