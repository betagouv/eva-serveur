module Pdf
  class GenerationJob < ApplicationJob
    queue_as :pdf

    def perform(token, html_content, nom_fichier)
      pdf_path = Pdf::Generator.generate(html_content)
      if pdf_path
        contenu = File.binread(pdf_path)
        File.delete(pdf_path)
        Pdf::GenerationChannel.diffuse(token, statut: "pret", nom_fichier: nom_fichier,
                                        contenu_base64: Base64.strict_encode64(contenu))
      else
        Pdf::GenerationChannel.diffuse(token, statut: "erreur")
      end
    end
  end
end
