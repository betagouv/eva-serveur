# frozen_string_literal: true

require 'rake_logger'

class ImporteurCommentaires
  class << self
    def importe(ligne, auteur)
      destinataire = Compte.find_by email: ligne[:mail]

      if destinataire.blank?
        RakeLogger.logger.info "Commentaire ignoré pour le compte inconnu : #{ligne[:mail]}"
      else
        cree_commentaires(auteur, destinataire, ligne)
      end
    end

    def cree_commentaires(auteur, destinataire, ligne)
      %i[utilisation_eva notes].each do |champ|
        ActiveAdmin::Comment.where(author: auteur,
                                   body: ligne[champ],
                                   resource: destinataire.structure,
                                   namespace: :admin)
                            .first_or_create
      end
    end
  end
end
