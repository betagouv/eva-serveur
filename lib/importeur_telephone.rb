# frozen_string_literal: true

require "rake_logger"

class ImporteurTelephone
  class << self
    def importe(ligne)
      compte = Compte.find_by email: ligne[:mail]
      return unless import_possible?(ligne, compte)

      RakeLogger.logger.info "Importe : #{ligne[:mail]},#{ligne[:telephone]}"
      compte.telephone = ligne[:telephone]
      compte.save!
    end

    private

    def import_possible?(ligne, compte)
      if compte.blank?
        RakeLogger.logger.warn "Téléphone ignoré pour le compte inconnu : " \
                               "#{ligne[:mail]} - #{ligne[:telephone]}"
        return false
      elsif compte.telephone.present?
        RakeLogger.logger.warn "#{compte.email}: téléphone #{compte.telephone} déjà présent; " \
                               "#{ligne[:telephone]} ignoré"
        return false
      end

      true
    end
  end
end
