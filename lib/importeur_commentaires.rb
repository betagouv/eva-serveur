# frozen_string_literal: true

require "rake_logger"

class ImporteurCommentaires
  class << self
    def importe(ligne, auteur)
      return if ligne[:notes].blank? && ligne[:utilisation_eva].blank?

      destinataire = Compte.find_by email: ligne[:mail]

      donnees = "#{ligne[:mail]},#{ligne[:utilisation_eva]},#{ligne[:notes]}"
      if destinataire.blank?
        RakeLogger.logger.warn "Commentaire ignoré pour le compte inconnu : #{donnees}"
      else
        RakeLogger.logger.info "Importe : #{donnees}"
        cree_commentaires(auteur, destinataire, ligne)
      end
    end

    def cree_commentaires(auteur, destinataire, ligne)
      %i[utilisation_eva notes].each do |champ|
        next if ligne[champ].blank?

        ActiveAdmin::Comment.where(author: auteur,
                                   body: "#{champ} : #{ligne[champ]}",
                                   resource: destinataire.structure,
                                   namespace: :admin)
                            .first_or_create
      end
    end
  end
end
