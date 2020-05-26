# frozen_string_literal: true

module Restitution
  module Metriques
    class Divise < Restitution::Metriques::Base
      def initialize(metrique_numerateur, metrique_denominateur)
        @metrique_numerateur = metrique_numerateur
        @metrique_denominateur = metrique_denominateur
      end

      def calcule(premier_parametre, deuxieme_parametre)
        numerateur = @metrique_numerateur.calcule(premier_parametre, deuxieme_parametre)
        return if numerateur.nil?

        denominateur = @metrique_denominateur.calcule(premier_parametre, deuxieme_parametre)
        return if denominateur.nil? || denominateur.zero?

        numerateur.fdiv(denominateur)
      end
    end
  end
end
